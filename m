From: Frank Blaschka <blaschka@linux.vnet.ibm.com>
Subject: [PATCH net] qeth: avoid buffer overflow in snmp ioctl
Date: Tue, 5 Nov 2013 15:14:00 +0100
Message-ID: <20131105141400.GA29477@tuxmaker.boeblingen.de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ursula Braun <ursula.braun@de.ibm.com>

Check user-defined length in snmp ioctl request and allow request
only if it fits into a qeth command buffer.

Signed-off-by: Ursula Braun <ursula.braun@de.ibm.com>
Signed-off-by: Frank Blaschka <frank.blaschka@de.ibm.com>
Reviewed-by: Heiko Carstens <heicars2@linux.vnet.ibm.com>
Reported-by: Nico Golde <nico@ngolde.de>
Reported-by: Fabian Yamaguchi <fabs@goesec.de>
Cc: <stable@vger.kernel.org>
---
 drivers/s390/net/qeth_core_main.c | 6 +++++-
 1 file changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/s390/net/qeth_core_main.c b/drivers/s390/net/qeth_core_main.c
index d7b66a2..642f623 100644
--- a/drivers/s390/net/qeth_core_main.c
+++ b/drivers/s390/net/qeth_core_main.c
@@ -4451,7 +4451,7 @@ int qeth_snmp_command(struct qeth_card *card, char __user *udata)
 	struct qeth_cmd_buffer *iob;
 	struct qeth_ipa_cmd *cmd;
 	struct qeth_snmp_ureq *ureq;
-	int req_len;
+	unsigned int req_len;
 	struct qeth_arp_query_info qinfo = {0, };
 	int rc = 0;
 
@@ -4467,6 +4467,10 @@ int qeth_snmp_command(struct qeth_card *card, char __user *udata)
 	/* skip 4 bytes (data_len struct member) to get req_len */
 	if (copy_from_user(&req_len, udata + sizeof(int), sizeof(int)))
 		return -EFAULT;
+	if (req_len > QETH_BUFSIZE - IPA_PDU_HEADER_SIZE
+				   - sizeof(struct qeth_ipacmd_hdr)
+				   - sizeof(struct qeth_ipacmd_setadpparms_hdr))
+		return -EINVAL;
 	ureq = memdup_user(udata, req_len + sizeof(struct qeth_snmp_ureq_hdr));
 	if (IS_ERR(ureq)) {
 		QETH_CARD_TEXT(card, 2, "snmpnome");
