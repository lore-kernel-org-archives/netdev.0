From: santosh prasad nayak <santoshprasadnayak@gmail.com>
Subject: Re: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
Date: Sun, 11 Mar 2012 14:46:48 +0530
Message-ID: <CAOD=uF4Vx581zvpAT0dHKjUkrdsiZo-DTNR352V8tALM_P2roA@mail.gmail.com>
References: <1330789663-30481-1-git-send-email-santoshprasadnayak@gmail.com>
	<13A253B3F9BEFE43B93C09CF75F63CAA81A8AB3B75@MNEXMB1.qlogic.org>
	<CAOD=uF7=28Bx4eSpGfP-uTND42k1xKE3tvQ6+exSJha9Yjf-_w@mail.gmail.com>
	<13A253B3F9BEFE43B93C09CF75F63CAA81A8AB3C07@MNEXMB1.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sony Chacko <sony.chacko@qlogic.com>,
	netdev <netdev@vger.kernel.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	"kernel-janitors@vger.kernel.org" <kernel-janitors@vger.kernel.org>
To: Rajesh Borundia <rajesh.borundia@qlogic.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <13A253B3F9BEFE43B93C09CF75F63CAA81A8AB3C07@MNEXMB1.qlogic.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thanks Rajesh for clarification.
Included all your inputs in the following patch.
This is for review not a formal one. Once review is done I will send a
formal patch.



diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
index 2eeac32..b5de8a7 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
@@ -954,7 +954,7 @@ typedef struct nx_mac_list_s {

 struct nx_vlan_ip_list {
 	struct list_head list;
-	u32 ip_addr;
+	__be32 ip_addr;
 };

 /*
@@ -1780,7 +1780,7 @@ int netxen_process_rcv_ring(struct
nx_host_sds_ring *sds_ring, int max);
 void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
 int netxen_config_intr_coalesce(struct netxen_adapter *adapter);
 int netxen_config_rss(struct netxen_adapter *adapter, int enable);
-int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int c=
md);
+int netxen_config_ipaddr(struct netxen_adapter *adapter, __be32 ip, in=
t cmd);
 int netxen_linkevent_request(struct netxen_adapter *adapter, int enabl=
e);
 void netxen_advert_link_change(struct netxen_adapter *adapter, int lin=
kup);
 void netxen_pci_camqm_read_2M(struct netxen_adapter *, u64, u64 *);
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
index 6f37470..59d5ee7 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
@@ -909,7 +909,7 @@ int netxen_config_rss(struct netxen_adapter
*adapter, int enable)
 	return rv;
 }

-int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip, int c=
md)
+int netxen_config_ipaddr(struct netxen_adapter *adapter, __be32 ip, in=
t cmd)
 {
 	nx_nic_req_t req;
 	u64 word;
@@ -922,7 +922,7 @@ int netxen_config_ipaddr(struct netxen_adapter
*adapter, u32 ip, int cmd)
 	req.req_hdr =3D cpu_to_le64(word);

 	req.words[0] =3D cpu_to_le64(cmd);
-	req.words[1] =3D cpu_to_le64(ip);
+	memcpy(&req.words[1], &ip, sizeof(u32));

 	rv =3D netxen_send_cmd_descs(adapter, (struct cmd_desc_type0 *)&req, =
1);
 	if (rv !=3D 0) {
@@ -1050,7 +1050,7 @@ int netxen_get_flash_mac_addr(struct
netxen_adapter *adapter, u64 *mac)
 	if (netxen_get_flash_block(adapter, offset, sizeof(u64), pmac) =3D=3D=
 -1)
 		return -1;

-	if (*mac =3D=3D cpu_to_le64(~0ULL)) {
+	if (*(__le64 *)mac =3D=3D cpu_to_le64(~0ULL)) {

 		offset =3D NX_OLD_MAC_ADDR_OFFSET +
 			(adapter->portnum * sizeof(u64));
@@ -1059,7 +1059,7 @@ int netxen_get_flash_mac_addr(struct
netxen_adapter *adapter, u64 *mac)
 					offset, sizeof(u64), pmac) =3D=3D -1)
 			return -1;

-		if (*mac =3D=3D cpu_to_le64(~0ULL))
+		if (*(__le64 *)mac =3D=3D cpu_to_le64(~0ULL))
 			return -1;
 	}
 	return 0;
@@ -2155,7 +2155,7 @@ static u32 netxen_md_rd_crb(struct
netxen_adapter *adapter,
 static u32
 netxen_md_rdrom(struct netxen_adapter *adapter,
 			struct netxen_minidump_entry_rdrom
-				*romEntry, u32 *data_buff)
+				*romEntry, __le32 *data_buff)
 {
 	int i, count =3D 0;
 	u32 size, lck_val;
diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
index 7648995..65a718f 100644
--- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
+++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
@@ -805,12 +805,12 @@ netxen_check_options(struct netxen_adapter *adapt=
er)
 	char brd_name[NETXEN_MAX_SHORT_NAME];
 	char serial_num[32];
 	int i, offset, val, err;
-	int *ptr32;
+	__le32 *ptr32;
 	struct pci_dev *pdev =3D adapter->pdev;

 	adapter->driver_mismatch =3D 0;

-	ptr32 =3D (int *)&serial_num;
+	ptr32 =3D (__le32 *)&serial_num;
 	offset =3D NX_FW_SERIAL_NUM_OFFSET;
 	for (i =3D 0; i < 8; i++) {
 		if (netxen_rom_fast_read(adapter, offset, &val) =3D=3D -1) {



On Sun, Mar 11, 2012 at 12:31 AM, Rajesh Borundia
<rajesh.borundia@qlogic.com> wrote:
>
>
>> -----Original Message-----
>> From: santosh prasad nayak [mailto:santoshprasadnayak@gmail.com]
>> Sent: Saturday, March 10, 2012 12:20 AM
>> To: Rajesh Borundia
>> Cc: Sony Chacko; netdev; linux-kernel; kernel-janitors@vger.kernel.o=
rg
>> Subject: Re: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
>>
>> On Fri, Mar 9, 2012 at 10:04 PM, Rajesh Borundia
>> <rajesh.borundia@qlogic.com> wrote:
>> >
>> >> -----Original Message-----
>> >> From: santosh nayak [mailto:santoshprasadnayak@gmail.com]
>> >> Sent: Saturday, March 03, 2012 9:18 PM
>> >> To: Sony Chacko
>> >> Cc: Rajesh Borundia; netdev; linux-kernel; kernel-
>> >> janitors@vger.kernel.org; Santosh Nayak
>> >> Subject: [PATCH 3/3] netxen: qlogic ethernet : Fix Endian Bug.
>> >>
>> >> From: Santosh Nayak <santoshprasadnayak@gmail.com>
>> >>
>> >> Fix endian bug.
>> >>
>> >> Signed-off-by: Santosh Nayak <santoshprasadnayak@gmail.com>
>> >> ---
>> >> =A0drivers/net/ethernet/qlogic/netxen/netxen_nic.h =A0 =A0| =A0 =A0=
4 ++--
>> >> =A0drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c | =A0 12 ++=
+++++--
>> ---
>> >> =A0.../net/ethernet/qlogic/netxen/netxen_nic_main.c =A0 | =A0 =A0=
2 +-
>> >> =A03 files changed, 10 insertions(+), 8 deletions(-)
>> >>
>> >> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
>> >> b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
>> >> index 2eeac32..b5de8a7 100644
>> >> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
>> >> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic.h
>> >> @@ -954,7 +954,7 @@ typedef struct nx_mac_list_s {
>> >>
>> >> =A0struct nx_vlan_ip_list {
>> >> =A0 =A0 =A0 struct list_head list;
>> >> - =A0 =A0 u32 ip_addr;
>> >> + =A0 =A0 __be32 ip_addr;
>> >> =A0};
>> >>
>> >> =A0/*
>> >> @@ -1780,7 +1780,7 @@ int netxen_process_rcv_ring(struct
>> >> nx_host_sds_ring *sds_ring, int max);
>> >> =A0void netxen_p3_free_mac_list(struct netxen_adapter *adapter);
>> >> =A0int netxen_config_intr_coalesce(struct netxen_adapter *adapter=
);
>> >> =A0int netxen_config_rss(struct netxen_adapter *adapter, int enab=
le);
>> >> -int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip,
>> int
>> >> cmd);
>> >> +int netxen_config_ipaddr(struct netxen_adapter *adapter, __be32 =
ip,
>> >> int cmd);
>> >> =A0int netxen_linkevent_request(struct netxen_adapter *adapter, i=
nt
>> >> enable);
>> >> =A0void netxen_advert_link_change(struct netxen_adapter *adapter,=
 int
>> >> linkup);
>> >> =A0void netxen_pci_camqm_read_2M(struct netxen_adapter *, u64, u6=
4 *);
>> >> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
>> >> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
>> >> index 6f37470..0f81287 100644
>> >> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
>> >> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_hw.c
>> >> @@ -909,10 +909,11 @@ int netxen_config_rss(struct netxen_adapter
>> >> *adapter, int enable)
>> >> =A0 =A0 =A0 return rv;
>> >> =A0}
>> >>
>> >> -int netxen_config_ipaddr(struct netxen_adapter *adapter, u32 ip,
>> int
>> >> cmd)
>> >> +int netxen_config_ipaddr(struct netxen_adapter *adapter, __be32 =
ip,
>> >> int cmd)
>> >> =A0{
>> >> =A0 =A0 =A0 nx_nic_req_t req;
>> >> =A0 =A0 =A0 u64 word;
>> >> + =A0 =A0 u64 ip_addr;
>> >> =A0 =A0 =A0 int rv;
>> >>
>> >> =A0 =A0 =A0 memset(&req, 0, sizeof(nx_nic_req_t));
>> >> @@ -922,7 +923,8 @@ int netxen_config_ipaddr(struct netxen_adapte=
r
>> >> *adapter, u32 ip, int cmd)
>> >> =A0 =A0 =A0 req.req_hdr =3D cpu_to_le64(word);
>> >>
>> >> =A0 =A0 =A0 req.words[0] =3D cpu_to_le64(cmd);
>> >> - =A0 =A0 req.words[1] =3D cpu_to_le64(ip);
>> >> + =A0 =A0 ip_addr =3D be32_to_cpu(ip);
>> >> + =A0 =A0 *(__be64 *)&req.words[1] =3D cpu_to_be64(ip_addr);
>> >
>>
>>
>> > Adapter requires ip value in big endian stored at lower 32 bit
>> address.
>> > The cpu_to_be64 will swap the lower 32 bit with higher 32 bit and
>> adapter
>> > Will get incorrect ip addr. Instead u can do.
>> >
>> > =A0 =A0 =A0 U32 *ip_addr;
>> > =A0 =A0 =A0 ip_addr =3D (u32 *)&req.words[1];
>> > =A0 =A0 =A0 *ip_addr =3D ip;
>>
>>
>> 1. =A0It looks incomplete.
>> =A0 =A0 In the function call "netxen_send_cmd_descs" we have to pass=
 "&req"
>> as
>> =A0 =A02nd argument =A0not =A0"ipaddr".
>
> =A0I should have sent a patch. This piece of code was just to show ho=
w to
> copy ip addr in =A0req.words[1].
>
>>
>> 2. Your above suggestion is with assumption that the data type of 2n=
d
>> argument "ip"
>> =A0 =A0 =A0in "netxen_config_ipaddr()" is still "u32". =A0This is no=
t true.
>>
>> =A0 =A0 =A0Some days back you suggested to change the data type to "=
__be32".
>> =A0In the present patch
>> =A0 =A0 =A0the "ip" =A0is in "__be32" format i.e already in Big endi=
an format
>> as per requirement.
>> =A0 =A0 =A0We need to only convert this 32 bit to 64 bit. =A0There a=
re two
>> ways:
>>
> =A0No I did not assume that ip is u32, ip is still __be32(ip value is=
 in form of big endian)
> =A0though I should have mentioned it explicitly. But the ip value sho=
uld be copied to lower 32 bit of req.words[1].
>
>
>> =A0 =A0 =A0a. =A0 *(__be64 *)&req.words[1] =3D ip; =A0 // auto conve=
rsion
> In big endian machine MSB is copied into MSB first. So ip will get co=
pied into higher 32 bit of
> req.words[1] but adapter requires it in lower 32 bit.
>>
>> =A0 =A0 =A0b. =A0 *(__be64 *)&req.words[1] =3D cpu_to_be64(be32_to_c=
pu(ip));
>> =A0 =A0 =A0 =A0 =A0 =A0 // explicit conversion.
>>
> If you follow second cpu_to_be64 it will swap lower 32 bit of ip with=
 higher 32 bit in little endian machine.
> But adapter requires it in lower 32 bit.
>
> Simple solution to copy ip in req.words[1] could be memcpy(&req.words=
[1], &ip, sizeof(u32));
>
>
>>
>> =A0Please correct me if I am wrong.
>>
>>
>> regards
>> Santosh
>>
>>
>>
>>
>> >
>> >
>> >>
>> >> =A0 =A0 =A0 rv =3D netxen_send_cmd_descs(adapter, (struct cmd_des=
c_type0
>> >> *)&req, 1);
>> >> =A0 =A0 =A0 if (rv !=3D 0) {
>> >> @@ -1050,7 +1052,7 @@ int netxen_get_flash_mac_addr(struct
>> >> netxen_adapter *adapter, u64 *mac)
>> >> =A0 =A0 =A0 if (netxen_get_flash_block(adapter, offset, sizeof(u6=
4), pmac)
>> =3D=3D
>> >> -1)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> >>
>> >> - =A0 =A0 if (*mac =3D=3D cpu_to_le64(~0ULL)) {
>> >> + =A0 =A0 if (*mac =3D=3D ~0ULL) {
>> >
>> > *mac is in little endian format so compare it with cpu_to_le64.
>> >
>> >>
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset =3D NX_OLD_MAC_ADDR_OFFSET +
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (adapter->portnum * s=
izeof(u64));
>> >> @@ -1059,7 +1061,7 @@ int netxen_get_flash_mac_addr(struct
>> >> netxen_adapter *adapter, u64 *mac)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 offset, sizeof(u64), pmac) =3D=3D
>> -1)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> >>
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 if (*mac =3D=3D cpu_to_le64(~0ULL))
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 if (*mac =3D=3D ~0ULL)
>> >
>> > *mac here is in little endian format so compare it with cpu_to_le6=
4.
>> >
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -1;
>> >> =A0 =A0 =A0 }
>> >> =A0 =A0 =A0 return 0;
>> >> @@ -2178,7 +2180,7 @@ lock_try:
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 NX_WR_DUMP_REG(FLASH_ROM_WINDOW, adap=
ter-
>> >ahw.pci_base0,
>> >> waddr);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 raddr =3D FLASH_ROM_DATA + (fl_addr &=
 0x0000FFFF);
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 NX_RD_DUMP_REG(raddr, adapter->ahw.pc=
i_base0, &val);
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 *data_buff++ =3D cpu_to_le32(val);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 *data_buff++ =3D val;
>> >
>> > It should be cpu_to_le32 as it is returned to tool which requires
>> > output in little endian.
>> >
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 fl_addr +=3D sizeof(val);
>> >> =A0 =A0 =A0 }
>> >> =A0 =A0 =A0 readl((void __iomem *)(adapter->ahw.pci_base0 +
>> >> NX_FLASH_SEM2_ULK));
>> >> diff --git a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
>> >> b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
>> >> index 8dc4a134..70783b4 100644
>> >> --- a/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
>> >> +++ b/drivers/net/ethernet/qlogic/netxen/netxen_nic_main.c
>> >> @@ -818,7 +818,7 @@ netxen_check_options(struct netxen_adapter
>> >> *adapter)
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 adapter->driver_misma=
tch =3D 1;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> >> - =A0 =A0 =A0 =A0 =A0 =A0 ptr32[i] =3D cpu_to_le32(val);
>> >> + =A0 =A0 =A0 =A0 =A0 =A0 ptr32[i] =3D val;
>> >
>> > Here val should be in little endian (cpu_to_le32) as it will be
>> referenced by byte array to print serial number.
>> >
>> >> =A0 =A0 =A0 =A0 =A0 =A0 =A0 offset +=3D sizeof(u32);
>> >> =A0 =A0 =A0 }
>> >>
>> >> --
>> >> 1.7.4.4
>> >>
>> >
>> >
>> > Sorry for Late reply.
>> >
>> > Rajesh
>> >
>
>
