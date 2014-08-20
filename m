From: Hayes Wang <hayeswang@realtek.com>
Subject: [PATCH net-next 4/4] r8152: support firmware files
Date: Wed, 20 Aug 2014 16:58:39 +0800
Message-ID: <1394712342-15778-20-Taiwan-albertk@realtek.com>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <nic_swsd@realtek.com>, <linux-kernel@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, Hayes Wang <hayeswang@realtek.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-16-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The firmware file is composed of the fw header and the commands. Each
command has the following type.

	cmd(2 bytes) + length(2 bytes) + data(variable bytes)

Before applying the firmware, the driver would check the fw header and
each command.

Signed-off-by: Hayes Wang <hayeswang@realtek.com>
---
 drivers/net/usb/r8152.c | 867 +++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 866 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
index 937d132..63542cc 100644
--- a/drivers/net/usb/r8152.c
+++ b/drivers/net/usb/r8152.c
@@ -21,10 +21,11 @@
 #include <linux/list.h>
 #include <linux/ip.h>
 #include <linux/ipv6.h>
+#include <linux/firmware.h>
 #include <net/ip6_checksum.h>
 
 /* Version Information */
-#define DRIVER_VERSION "v1.06.0 (2014/03/03)"
+#define DRIVER_VERSION "v1.07.0 (2014/08/20)"
 #define DRIVER_AUTHOR "Realtek linux nic maintainers <nic_swsd@realtek.com>"
 #define DRIVER_DESC "Realtek RTL8152/RTL8153 Based USB Ethernet Adapters"
 #define MODULENAME "r8152"
@@ -577,6 +578,16 @@ struct r8152 {
 		void (*unload)(struct r8152 *);
 	} rtl_ops;
 
+	struct rtl_fw {
+		const struct firmware *fw;
+
+#define RTL_VER_SIZE		32
+
+		char version[RTL_VER_SIZE];
+		u8 *code;
+		size_t code_size;
+	} rtl_fw;
+
 	int intr_interval;
 	u32 saved_wolopts;
 	u32 msg_enable;
@@ -1321,6 +1332,852 @@ err1:
 	return -ENOMEM;
 }
 
+#define FW_SIGNATURE	0x0bda8152
+
+enum fw_cmd {
+	FW_CMD_INVALID = 0,
+
+	FW_CMD_GENERIC_WRITE,
+	FW_CMD_WRITE_BYTE,
+	FW_CMD_WRITE_WORD,
+	FW_CMD_WRITE_DWORD,
+	FW_CMD_READ_BYTE,
+	FW_CMD_READ_WORD,
+	FW_CMD_READ_DWORD,
+	FW_CMD_W0W1_BYTE,
+	FW_CMD_W0W1_WORD,
+	FW_CMD_W0W1_DWORD,
+	FW_CMD_W0W1_CURRENT,
+	FW_CMD_WRITE_CURRENT_BYTE,
+	FW_CMD_WRITE_CURRENT_WORD,
+	FW_CMD_WRITE_CURRENT_DWORD,
+	FW_CMD_CMP,
+	FW_CMD_JMP,
+	FW_CMD_JE,
+	FW_CMD_JNE,
+	FW_CMD_JA,
+	FW_CMD_JAE,
+	FW_CMD_JB,
+	FW_CMD_JBE,
+	FW_CMD_CX,
+	FW_CMD_LOOP,
+	FW_CMD_LOOPE,
+	FW_CMD_LOOPNE,
+	FW_CMD_USLEEP,
+
+	FW_CMD_END,
+	FW_CMD_MAX
+};
+
+struct fw_cmd_generic {
+	__le16 cmd;
+	__le16 length;
+} __packed;
+
+struct fw_cmd_most_used {
+	__le16 type;
+	__le16 addr;
+} __packed;
+
+struct fw_header {
+	__le32	signature;
+	char	version[RTL_VER_SIZE];
+	__le32	fw_start;
+	__le32	fw_len;
+} __packed;
+
+static bool rtl_fw_format_ok(struct rtl_fw *rtl_fw)
+{
+	const struct firmware *fw = rtl_fw->fw;
+	struct fw_header *fw_header = (struct fw_header *)fw->data;
+	char *version = rtl_fw->version;
+	size_t i, size, start;
+	u8 checksum = 0;
+	bool rc = false;
+
+	if (fw->size < sizeof(*fw_header))
+		goto out;
+
+	if (__le32_to_cpu(fw_header->signature) != FW_SIGNATURE)
+		goto out;
+
+	start = le32_to_cpu(fw_header->fw_start);
+	if (start > fw->size)
+		goto out;
+
+	size = le32_to_cpu(fw_header->fw_len);
+	if (size > (fw->size - start))
+		goto out;
+
+	for (i = 0; i < fw->size; i++)
+		checksum += fw->data[i];
+	if (checksum != 0)
+		goto out;
+
+	memcpy(version, fw_header->version, RTL_VER_SIZE);
+
+	rtl_fw->code = (u8 *)(fw->data + start);
+	rtl_fw->code_size = size;
+
+	version[RTL_VER_SIZE - 1] = 0;
+
+	rc = true;
+out:
+	return rc;
+}
+
+static void rtl_fw_get_info2(u8 *d2, u16 *ptype, u16 *paddr)
+{
+	struct fw_cmd_most_used info2;
+
+	memcpy(&info2, d2, sizeof(info2));
+	*ptype = __le16_to_cpu(info2.type);
+	*paddr = __le16_to_cpu(info2.addr);
+}
+
+static bool rtl_fw_data_ok(u8 *d, size_t total)
+{
+	u16 cmd, len, type, addr, byteen, size, cx = 0;
+	struct fw_cmd_generic op;
+	bool result = false;
+	__le16 le16_data;
+	__le32 le32_data;
+	size_t i = 0, j;
+
+	while (i < total) {
+		if (i + sizeof(op) > total)
+			goto result_return;
+
+		memcpy(&op, &d[i], sizeof(op));
+		cmd = __le16_to_cpu(op.cmd);
+		len = __le16_to_cpu(op.length);
+		j = i + sizeof(op);
+
+		switch (cmd) {
+		case FW_CMD_GENERIC_WRITE:
+			/* struct fw_cmd_generic_write {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le16 data_length;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			j += sizeof(struct fw_cmd_most_used);
+
+			/* addr size must be the multiple of 4 */
+			if (addr & 3)
+				goto result_return;
+
+			byteen = type & 0xff;
+			type = type & ~0xff;
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			j += sizeof(le16_data);
+			size = __le16_to_cpu(le16_data);
+
+			/* data size must be the multiple of 4 */
+			if (size & 3)
+				goto result_return;
+
+			size += sizeof(struct fw_cmd_most_used) + sizeof(size);
+
+			break;
+
+		case FW_CMD_WRITE_BYTE:
+			/* struct fw_cmd_generic_write {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	u8 data;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if (type & 0xff)
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used) + 1;
+			break;
+
+		case FW_CMD_WRITE_WORD:
+			/* struct fw_cmd_ocp_write_word {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le16 data;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if ((type & 0xff) || (addr & 1))
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used) +
+			       sizeof(le16_data);
+			break;
+
+		case FW_CMD_WRITE_DWORD:
+			/* struct fw_cmd_ocp_write_dword {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le32 data;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if ((type & 0xff) || (addr & 3))
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used) +
+			       sizeof(le32_data);
+			break;
+
+		case FW_CMD_READ_BYTE:
+		case FW_CMD_WRITE_CURRENT_BYTE:
+			/* struct fw_cmd_write_current {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if (type & 0xff)
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used);
+			break;
+
+		case FW_CMD_READ_WORD:
+		case FW_CMD_WRITE_CURRENT_WORD:
+			/* struct fw_cmd_write_current {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if ((type & 0xff) || (addr & 1))
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used);
+			break;
+
+		case FW_CMD_READ_DWORD:
+		case FW_CMD_WRITE_CURRENT_DWORD:
+			/* struct fw_cmd_write_current {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if ((type & 0xff) || (addr & 3))
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used);
+			break;
+
+		case FW_CMD_W0W1_BYTE:
+			/* struct fw_cmd_ocp_w0w1_byte {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	u8 w0;
+			 *	u8 w1;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if (type & 0xff)
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used) + 2;
+			break;
+
+		case FW_CMD_W0W1_WORD:
+			/* struct fw_cmd_ocp_w0w1_word {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le16 w0;
+			 *	__le16 w1;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if ((type & 0xff) || (addr & 1))
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used) +
+			       sizeof(le16_data) * 2;
+			break;
+
+		case FW_CMD_W0W1_DWORD:
+			/* struct fw_cmd_ocp_w0w1_dword {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le32 w0;
+			 *	__le32 w1;
+			 * };
+			 */
+
+			if ((j + sizeof(struct fw_cmd_most_used)) > total)
+				goto result_return;
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+
+			if ((type & 0xff) || (addr & 3))
+				goto result_return;
+
+			size = sizeof(struct fw_cmd_most_used) +
+			       sizeof(le32_data) * 2;
+			break;
+
+		case FW_CMD_CMP:
+			/* struct fw_cmd_compare {
+			 *	struct fw_cmd_generic op;
+			 *	__le32 data;
+			 * };
+			 */
+
+			size = sizeof(le32_data);
+			break;
+
+		case FW_CMD_JMP:
+		case FW_CMD_JE:
+		case FW_CMD_JNE:
+		case FW_CMD_JA:
+		case FW_CMD_JAE:
+		case FW_CMD_JB:
+		case FW_CMD_JBE:
+		case FW_CMD_LOOP:
+		case FW_CMD_LOOPE:
+		case FW_CMD_LOOPNE:
+			/* struct fw_cmd_jump {
+			 *	struct fw_cmd_generic op;
+			 *	__le16 offset;
+			 * };
+			 */
+
+			if (j + sizeof(le16_data) > total)
+				goto result_return;
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			j = (short)__le16_to_cpu(le16_data);
+
+			j += sizeof(op) + len + i;
+			if (j < 0 || j > total)
+				goto result_return;
+
+			size = sizeof(le16_data);
+			break;
+
+		case FW_CMD_CX:
+		case FW_CMD_USLEEP:
+			/* struct fw_cmd_cx {
+			 *	struct fw_cmd_generic op;
+			 *	__le16 cx;
+			 * };
+			 */
+
+			if (j + sizeof(le16_data) > total)
+				goto result_return;
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			cx = __le16_to_cpu(le16_data);
+			if (cx == 0)
+				goto result_return;
+
+			size = sizeof(le16_data);
+			break;
+
+		case FW_CMD_W0W1_CURRENT:
+			/* struct fw_cmd_ocp_w0w1_current {
+			 *	struct fw_cmd_generic op;
+			 *	__le32 w0;
+			 *	__le32 w1;
+			 * };
+			 */
+			size = sizeof(le32_data) * 2;
+			break;
+
+		case FW_CMD_END:
+			size = 0;
+			goto result_return;
+
+		default:
+			goto result_return;
+		}
+
+		if (len != size)
+			goto result_return;
+
+		i += sizeof(op) + len;
+	}
+
+	if (i <= total)
+		result = true;
+
+result_return:
+	return result;
+}
+
+static bool rtl_check_firmware(struct r8152 *tp, struct rtl_fw *fw)
+{
+	bool fw_ok = false;
+
+	if (!rtl_fw_format_ok(&tp->rtl_fw))
+		goto out;
+
+	if (rtl_fw_data_ok(tp->rtl_fw.code, tp->rtl_fw.code_size))
+		fw_ok = true;
+
+out:
+	return fw_ok;
+}
+
+static void rtl_fw_write(struct r8152 *tp, u8 *d, size_t total)
+{
+	u16 cmd, len, type, addr, byteen, size, cx = 0, us;
+	u32 ocp_data = 0, compare = 0;
+	struct fw_cmd_generic op;
+	__le16 le16_data;
+	__le32 le32_data;
+	size_t i = 0, j;
+
+	while (i < total) {
+		memcpy(&op, &d[i], sizeof(op));
+		cmd = __le16_to_cpu(op.cmd);
+		len = __le16_to_cpu(op.length);
+		j = i + sizeof(op);
+
+		switch (cmd) {
+		case FW_CMD_GENERIC_WRITE:
+			/* struct fw_cmd_generic_write {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le16 data_length;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			j += sizeof(struct fw_cmd_most_used);
+
+			byteen = type & 0xff;
+			type = type & ~0xff;
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			j += sizeof(le16_data);
+			size = __le16_to_cpu(le16_data);
+
+			generic_ocp_write(tp, addr, byteen, size, &d[j], type);
+			break;
+
+		case FW_CMD_WRITE_BYTE:
+			/* struct fw_cmd_generic_write {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	u8 data;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			j += sizeof(struct fw_cmd_most_used);
+
+			ocp_data = d[j];
+			ocp_write_byte(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_WRITE_WORD:
+			/* struct fw_cmd_ocp_write_word {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le16 data;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			j += sizeof(struct fw_cmd_most_used);
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			ocp_data = __le16_to_cpu(le16_data);
+
+			ocp_write_word(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_WRITE_DWORD:
+			/* struct fw_cmd_ocp_write_dword {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le32 data;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			j += sizeof(struct fw_cmd_most_used);
+
+			memcpy(&le32_data, &d[j], sizeof(le32_data));
+			ocp_data = __le32_to_cpu(le32_data);
+
+			ocp_write_dword(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_READ_BYTE:
+			/* struct fw_cmd_ocp_read {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			ocp_data = ocp_read_byte(tp, type, addr);
+			break;
+
+		case FW_CMD_READ_WORD:
+			/* struct fw_cmd_ocp_read {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			ocp_data = ocp_read_word(tp, type, addr);
+			break;
+
+		case FW_CMD_READ_DWORD:
+			/* struct fw_cmd_ocp_read {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			ocp_data = ocp_read_dword(tp, type, addr);
+			break;
+
+		case FW_CMD_W0W1_BYTE:
+			/* struct fw_cmd_ocp_w0w1_byte {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	u8 w0;
+			 *	u8 w1;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			j += sizeof(struct fw_cmd_most_used);
+
+			ocp_data = ocp_read_byte(tp, type, addr);
+			ocp_data &= ~d[j++];
+			ocp_data |= d[j++];
+			ocp_write_byte(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_W0W1_WORD:
+			/* struct fw_cmd_ocp_w0w1_word {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le16 w0;
+			 *	__le16 w1;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			j += sizeof(struct fw_cmd_most_used);
+
+			ocp_data = ocp_read_word(tp, type, addr);
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			j += sizeof(le16_data);
+			ocp_data &= ~__le16_to_cpu(le16_data);
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			j += sizeof(le16_data);
+			ocp_data |= __le16_to_cpu(le16_data);
+
+			ocp_write_word(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_W0W1_DWORD:
+			/* struct fw_cmd_ocp_w0w1_dword {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 *	__le32 w0;
+			 *	__le32 w1;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			j += sizeof(struct fw_cmd_most_used);
+
+			ocp_data = ocp_read_dword(tp, type, addr);
+
+			memcpy(&le32_data, &d[j], sizeof(le32_data));
+			j += sizeof(le32_data);
+			ocp_data &= ~__le32_to_cpu(le32_data);
+
+			memcpy(&le32_data, &d[j], sizeof(le32_data));
+			j += sizeof(le32_data);
+			ocp_data |= __le32_to_cpu(le32_data);
+
+			ocp_write_dword(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_W0W1_CURRENT:
+			/* struct fw_cmd_ocp_w0w1_current {
+			 *	struct fw_cmd_generic op;
+			 *	__le32 w0;
+			 *	__le32 w1;
+			 * };
+			 */
+
+			memcpy(&le32_data, &d[j], sizeof(le32_data));
+			j += sizeof(le32_data);
+			ocp_data &= ~__le32_to_cpu(le32_data);
+
+			memcpy(&le32_data, &d[j], sizeof(le32_data));
+			j += sizeof(le32_data);
+			ocp_data |= __le32_to_cpu(le32_data);
+			break;
+
+		case FW_CMD_WRITE_CURRENT_BYTE:
+			/* struct fw_cmd_write_current {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			ocp_write_byte(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_WRITE_CURRENT_WORD:
+			/* struct fw_cmd_write_current {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			ocp_write_word(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_WRITE_CURRENT_DWORD:
+			/* struct fw_cmd_write_current {
+			 *	struct fw_cmd_generic op;
+			 *	struct fw_cmd_most_used info2;
+			 * };
+			 */
+
+			rtl_fw_get_info2(&d[j], &type, &addr);
+			ocp_write_dword(tp, type, addr, ocp_data);
+			break;
+
+		case FW_CMD_CMP:
+			/* struct fw_cmd_compare {
+			 *	struct fw_cmd_generic op;
+			 *	__le32 data;
+			 * };
+			 */
+
+			memcpy(&le32_data, &d[j], sizeof(le32_data));
+			compare = __le32_to_cpu(le32_data);
+			break;
+
+		case FW_CMD_JMP:
+			/* struct fw_cmd_jump {
+			 *	struct fw_cmd_generic op;
+			 *	__le16 offset;
+			 * };
+			 */
+do_jump:
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			j = (short)__le16_to_cpu(le16_data);
+
+			i += sizeof(op) + len + j;
+			continue;
+
+		case FW_CMD_JE:
+			if (ocp_data == compare)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_JNE:
+			if (ocp_data != compare)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_JA:
+			if (ocp_data > compare)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_JAE:
+			if (ocp_data >= compare)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_JB:
+			if (ocp_data < compare)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_JBE:
+			if (ocp_data <= compare)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_CX:
+			/* struct fw_cmd_cx {
+			 *	struct fw_cmd_generic op;
+			 *	__le16 cx;
+			 * };
+			 */
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			cx = __le16_to_cpu(le16_data);
+			break;
+
+		case FW_CMD_LOOP:
+			if (--cx > 0)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_LOOPE:
+			if (--cx > 0 && ocp_data == compare)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_LOOPNE:
+			if (--cx > 0 && ocp_data != compare)
+				goto do_jump;
+
+			break;
+
+		case FW_CMD_USLEEP:
+			/* struct fw_cmd_usleep {
+			 *	struct fw_cmd_generic op;
+			 *	__le16 us;
+			 * };
+			 */
+
+			memcpy(&le16_data, &d[j], sizeof(le16_data));
+			us = __le16_to_cpu(le16_data);
+			usleep_range(us , us * 4);
+			break;
+
+		case FW_CMD_END:
+		default:
+			return;
+		}
+
+		i += sizeof(op) + len;
+	}
+}
+
+static void rtl_release_firmware(struct r8152 *tp)
+{
+	if (!IS_ERR_OR_NULL(tp->rtl_fw.fw)) {
+		release_firmware(tp->rtl_fw.fw);
+		tp->rtl_fw.fw = NULL;
+	}
+}
+
+static void rtl_request_firmware(struct r8152 *tp)
+{
+	char *fw_name = NULL;
+
+	if (tp->rtl_fw.fw)
+		goto out_request;
+
+	switch (tp->version) {
+	case RTL_VER_01:
+		fw_name = "rtl_nic/rtl8152-1.fw";
+		break;
+	case RTL_VER_02:
+		fw_name = "rtl_nic/rtl8152-2.fw";
+		break;
+	case RTL_VER_03:
+		fw_name = "rtl_nic/rtl8153-1.fw";
+		break;
+	case RTL_VER_04:
+		fw_name = "rtl_nic/rtl8153-2.fw";
+		break;
+	case RTL_VER_05:
+		fw_name = "rtl_nic/rtl8153-3.fw";
+		break;
+	default:
+		goto out_request;
+	}
+
+	if (request_firmware(&tp->rtl_fw.fw, fw_name, &tp->netdev->dev) < 0)
+		goto err_warn;
+
+	if (!rtl_check_firmware(tp, &tp->rtl_fw)) {
+		netif_err(tp, ifup, tp->netdev, "invalid firwmare\n");
+		goto err_release_firmware;
+	}
+
+out_request:
+	return;
+
+err_release_firmware:
+	release_firmware(tp->rtl_fw.fw);
+err_warn:
+	netif_warn(tp, ifup, tp->netdev, "unable to load firmware patch %s\n",
+		   fw_name);
+	tp->rtl_fw.fw = ERR_PTR(-ENOENT);
+	goto out_request;
+}
+
+static void rtl_apply_firmware(struct r8152 *tp)
+{
+	if (!IS_ERR_OR_NULL(tp->rtl_fw.fw)) {
+		rtl_fw_write(tp, tp->rtl_fw.code, tp->rtl_fw.code_size);
+		tp->ocp_base = 0;
+	}
+}
+
 static struct tx_agg *r8152_get_tx_agg(struct r8152 *tp)
 {
 	struct tx_agg *agg = NULL;
@@ -2226,6 +3083,7 @@ static void r8152b_hw_phy_cfg(struct r8152 *tp)
 
 	r8152b_disable_aldps(tp);
 
+	rtl_apply_firmware(tp);
 
 	r8152b_enable_aldps(tp);
 	set_bit(PHY_RESET, &tp->flags);
@@ -2381,6 +3239,7 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
 		r8152_mdio_write(tp, MII_BMCR, data);
 	}
 
+	rtl_apply_firmware(tp);
 
 	if (tp->version == RTL_VER_03) {
 		data = ocp_reg_read(tp, OCP_EEE_CFG);
@@ -2802,6 +3661,7 @@ static int rtl8152_open(struct net_device *netdev)
 			tp->rtl_ops.disable(tp);
 	}
 
+	rtl_request_firmware(tp);
 	tp->rtl_ops.up(tp);
 
 	rtl8152_set_speed(tp, AUTONEG_ENABLE,
@@ -3130,6 +3990,10 @@ static void rtl8152_get_drvinfo(struct net_device *netdev,
 	strlcpy(info->driver, MODULENAME, sizeof(info->driver));
 	strlcpy(info->version, DRIVER_VERSION, sizeof(info->version));
 	usb_make_path(tp->udev, info->bus_info, sizeof(info->bus_info));
+	BUILD_BUG_ON(sizeof(info->fw_version) < sizeof(tp->rtl_fw.version));
+	if (!IS_ERR_OR_NULL(tp->rtl_fw.fw))
+		strlcpy(info->fw_version, tp->rtl_fw.version,
+			sizeof(info->fw_version));
 }
 
 static
@@ -3514,6 +4378,7 @@ static void rtl8152_disconnect(struct usb_interface *intf)
 		tasklet_kill(&tp->tl);
 		unregister_netdev(tp->netdev);
 		tp->rtl_ops.unload(tp);
+		rtl_release_firmware(tp);
 		free_netdev(tp->netdev);
 	}
 }
-- 
1.9.3
