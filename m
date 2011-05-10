From: Sebastian.Poehn@Belden.com
Subject: [PATCH 3/3] RFC gianfar: add rx_ntuple feature
Date: Tue, 10 May 2011 08:55:46 -0400
Message-ID: <OF56049997.B9542799-ON8525788C.00470640-8525788C.00470642@BeldenCDT.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: "netdev" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.belden.com ([12.161.118.91]:52001 "EHLO mx2.belden.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753146Ab1EJNKz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 09:10:55 -0400
In-Reply-To: 
References: 
MIME-Version: 1.0
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This  is the main part. Functionality to add and remove ntuples, conver=
sion  from ntuple to hardware binary rx filer format, optimization of h=
ardware  filer table entries and extended hardware capability check.

--- gianfar_ethtool.c.orig	2011-05-10 11:45:33.301745000 +0200
+++ gianfar_ethtool.c	2011-05-10 13:27:23.041744819 +0200
@@ -42,6 +42,8 @@
=A0
=A0extern void gfar_start(struct net_device *dev);
=A0extern int gfar_clean_rx_ring(struct gfar_priv_rx_q *rx_queue, int r=
x_work_limit);
+extern void sort(void *, size_t, size_t, int(*cmp_func)(const void *,
+		const void *), void(*swap_func)(void *, void *, int size));
=A0
=A0#define GFAR_MAX_COAL_USECS 0xffff
=A0#define GFAR_MAX_COAL_FRAMES 0xff
@@ -787,6 +789,1011 @@ static int gfar_set_nfc(struct net_devic
=A0	return ret;
=A0}
=A0
+/*Global pointer on table*/
+struct filer_table *ref;
+u32 filer_index;
+struct interf *queue;
+
+enum nop {
+	ASC =3D 0, DESC =3D 1
+} row;
+
+static inline void toggle_order(void)
+{
+	row ^=3D 1;
+}
+
+static int my_comp(const void *a, const void *b)
+{
+
+	signed int temp;
+	if (*(u32 *) a > *(u32 *) b)
+		temp =3D -1;
+	else if (*(u32 *) a =3D=3D *(u32 *) b)
+		temp =3D 0;
+	else
+		temp =3D 1;
+
+	if (row =3D=3D DESC)
+		return temp;
+	else
+		return -temp;
+}
+
+static void my_swap(void *a, void *b, int size)
+{
+	u32 t1 =3D *(u32 *) a;
+	u32 t2 =3D *(u32 *) (a + 4);
+	u32 t3 =3D *(u32 *) (a + 8);
+	u32 t4 =3D *(u32 *) (a + 12);
+	*(u32 *) a =3D *(u32 *) b;
+	*(u32 *) (a + 4) =3D *(u32 *) (b + 4);
+	*(u32 *) (a + 8) =3D *(u32 *) (b + 8);
+	*(u32 *) (a + 12) =3D *(u32 *) (b + 12);
+	*(u32 *) b =3D t1;
+	*(u32 *) (b + 4) =3D t2;
+	*(u32 *) (b + 8) =3D t3;
+	*(u32 *) (b + 12) =3D t4;
+}
+
+/*Write a mask to hardware*/
+static inline void set_mask(u32 mask)
+{
+	ref->fe[filer_index].ctrl =3D RQFCR_AND | RQFCR_PID_MASK
+			| RQFCR_CMP_EXACT;
+	ref->fe[filer_index].prop =3D mask;
+	filer_index++;
+}
+
+/*Sets parse bits (e.g. IP or TCP)*/
+static void set_parse_bits(u32 host, u32 mask)
+{
+	set_mask(mask);
+	ref->fe[filer_index].ctrl =3D RQFCR_CMP_EXACT | RQFCR_PID_PARSE
+			| RQFCR_AND;
+	ref->fe[filer_index].prop =3D host;
+	filer_index++;
+}
+
+/*For setting a tuple of host,mask of type flag
+ *Example:
+ *IP-Src =3D 10.0.0.0/255.0.0.0
+ *host: 0x0A000000 mask: FF000000 flag: RQFPR_IPV4
+ *Note:
+ *For better usage of hardware 16 and 8 bit masks should be filled up
+ *with ones*/
+static void set_attribute(unsigned int host, unsigned int mask,
+		unsigned int flag)
+{
+	if (host || ~mask) {
+		/*This is to deal with masks smaller than 32bit
+		 * and for special processing of MAC-filtering and
+		 * VLAN-filtering*/
+		switch (flag) {
+		/*3bit*/
+		case RQFCR_PID_PRI:
+			if (((host & 0x7) =3D=3D 0) && ((mask & 0x7) =3D=3D 0))
+				return;
+			host &=3D 0x7;
+			break;
+			/*8bit*/
+		case RQFCR_PID_L4P:
+		case RQFCR_PID_TOS:
+			if (!(mask & 0xFF))
+				mask =3D 0xFFFFFFFF;
+			break;
+			/*12bit*/
+		case RQFCR_PID_VID:
+			if (((host & 0xFFF) =3D=3D 0) && ((mask & 0xFFF) =3D=3D 0))
+				return;
+			host &=3D 0xFFF;
+			break;
+			/*16bit*/
+		case RQFCR_PID_DPT:
+		case RQFCR_PID_SPT:
+		case RQFCR_PID_ETY:
+			if (!(mask & 0xFFFF))
+				mask =3D 0xFFFFFFFF;
+			break;
+			/*24bit*/
+		case RQFCR_PID_DAH:
+		case RQFCR_PID_DAL:
+		case RQFCR_PID_SAH:
+		case RQFCR_PID_SAL:
+			host &=3D 0x00FFFFFF;
+			break;
+			/*for all real 32bit masks*/
+		default:
+			if (!mask)
+				mask =3D 0xFFFFFFFF;
+			break;
+		}
+
+		set_mask(mask);
+		ref->fe[filer_index].ctrl =3D RQFCR_CMP_EXACT | RQFCR_AND | flag;
+		ref->fe[filer_index].prop =3D host;
+		filer_index++;
+	}
+}
+
+/*Translates host and mask for UDP,TCP or SCTP*/
+static void set_basic_ip(struct ethtool_tcpip4_spec *host,
+		struct ethtool_tcpip4_spec *mask)
+{
+	set_attribute(host->ip4src, mask->ip4src, RQFCR_PID_SIA);
+	set_attribute(host->ip4dst, mask->ip4dst, RQFCR_PID_DIA);
+	set_attribute(host->pdst, mask->pdst | 0xFFFF0000, RQFCR_PID_DPT);
+	set_attribute(host->psrc, mask->psrc | 0xFFFF0000, RQFCR_PID_SPT);
+	set_attribute(host->tos, mask->tos | 0xFFFFFF00, RQFCR_PID_TOS);
+}
+
+/*Translates host and mask for USER-IP4*/
+static inline void set_user_ip(struct ethtool_usrip4_spec *host,
+		struct ethtool_usrip4_spec *mask)
+{
+
+	set_attribute(host->ip4src, mask->ip4src, RQFCR_PID_SIA);
+	set_attribute(host->ip4dst, mask->ip4dst, RQFCR_PID_DIA);
+	set_attribute(host->tos, mask->tos | 0xFFFFFF00, RQFCR_PID_TOS);
+	set_attribute(host->proto, mask->proto | 0xFFFFFF00, RQFCR_PID_L4P);
+	set_attribute(host->l4_4_bytes, mask->l4_4_bytes, RQFCR_PID_ARB);
+
+}
+
+/*Translates host and mask for ETHER spec*/
+static inline void set_ether(struct ethhdr *host, struct ethhdr *mask)
+{
+	u32 upper_temp_mask =3D 0;
+	u32 lower_temp_mask =3D 0;
+	/*Source address*/
+	if (!(is_zero_ether_addr(host->h_source) && is_broadcast_ether_addr(
+			mask->h_source))) {
+		if (is_zero_ether_addr(mask->h_source)) {
+			upper_temp_mask =3D 0xFFFFFFFF;
+			lower_temp_mask =3D 0xFFFFFFFF;
+		} else {
+			upper_temp_mask =3D mask->h_source[0] << 16
+					| mask->h_source[1] << 8
+					| mask->h_source[2] | 0xFF000000;
+			lower_temp_mask =3D mask->h_source[3] << 16
+					| mask->h_source[4] << 8
+					| mask->h_source[5] | 0xFF000000;
+		}
+		/*Upper 24bit*/
+		set_attribute(0x80000000 | host->h_source[0] << 16
+				| host->h_source[1] << 8 | host->h_source[2],
+				upper_temp_mask, RQFCR_PID_SAH);
+		/*And the same for the lower part*/
+		set_attribute(0x80000000 | host->h_source[3] << 16
+				| host->h_source[4] << 8 | host->h_source[5],
+				lower_temp_mask, RQFCR_PID_SAL);
+	}
+	/*Destination address*/
+	if (!(is_zero_ether_addr(host->h_dest) && is_broadcast_ether_addr(
+			mask->h_dest))) {
+
+		/*Special for destination is limited broadcast*/
+		if ((is_broadcast_ether_addr(host->h_dest)
+				&& is_zero_ether_addr(mask->h_dest))) {
+			set_parse_bits(RQFPR_EBC, RQFPR_EBC);
+		} else {
+
+			if (is_zero_ether_addr(mask->h_dest)) {
+				upper_temp_mask =3D 0xFFFFFFFF;
+				lower_temp_mask =3D 0xFFFFFFFF;
+			} else {
+				upper_temp_mask =3D mask->h_dest[0] << 16
+						| mask->h_dest[1] << 8
+						| mask->h_dest[2] | 0xFF000000;
+				lower_temp_mask =3D mask->h_dest[3] << 16
+						| mask->h_dest[4] << 8
+						| mask->h_dest[5] | 0xFF000000;
+			}
+
+			/*Upper 24bit*/
+			set_attribute(0x80000000 | host->h_dest[0] << 16
+					| host->h_dest[1] << 8
+					| host->h_dest[2], upper_temp_mask,
+					RQFCR_PID_DAH);
+			/*And the same for the lower part*/
+			set_attribute(0x80000000 | host->h_dest[3] << 16
+					| host->h_dest[4] << 8
+					| host->h_dest[5], lower_temp_mask,
+					RQFCR_PID_DAL);
+		}
+	}
+
+	/*Set Ethertype*/
+	if ((host->h_proto || ~(mask->h_proto | 0xFFFF0000))) {
+		set_attribute(host->h_proto, mask->h_proto | 0xFFFF0000,
+				RQFCR_PID_ETY);
+	}
+
+	/*
+	 * Question: What the hell does the 0x80000000 do?
+	 * Answer: It is just a dirty hack to prevent the setAtribute()
+	 * to ignore a half MAC address which is like 0x000000/0xFFFFFF
+	 */
+
+}
+
+/*For debugging*/
+void print_hw(struct gfar_private *p)
+{
+
+	int i =3D 0;
+	unsigned int a, b;
+	printk(KERN_DEBUG "No. =A0Control =A0 Properties\n");
+	for (i =3D 0; i < 25; i++) {
+		gfar_read_filer(p, i, &a, &b);
+		printk(KERN_DEBUG "%3d =A0%08x =A0%08x\n", i, a, b);
+	}
+	printk(KERN_DEBUG "Data on hardware: %d\n", filer_index);
+}
+
+/*Copy size filer entries*/
+static inline void copy_filer_entries(struct filer_entry dst[0],
+		struct filer_entry src[0], s32 size)
+{
+	while (size > 0) {
+		size--;
+		dst[size].ctrl =3D src[size].ctrl;
+		dst[size].prop =3D src[size].prop;
+	}
+}
+
+/*Delete the contents of the filer-table between start and end
+ * and collapse them*/
+static int trim_filer_entries(int begin, int end)
+{
+	int length;
+	if (end > MAX_FILER_CACHE_IDX || begin > MAX_FILER_CACHE_IDX || begin
+			< 0 || end < 0 || end < begin)
+		return -EOUTOFRANGE;
+
+	length =3D (end - begin) + 1;
+
+	end++;
+
+	/*Copy*/
+	while (end < filer_index) {
+		ref->fe[begin].ctrl =3D ref->fe[end].ctrl;
+		ref->fe[begin++].prop =3D ref->fe[end++].prop;
+
+	}
+	/*Fill up with don't cares*/
+	while (begin <=3D filer_index) {
+		ref->fe[begin].ctrl =3D 0x60;
+		ref->fe[begin].prop =3D 0xFFFFFFFF;
+		begin++;
+	}
+
+	filer_index -=3D length;
+	return 0;
+}
+
+/*Make space on the wanted location*/
+static inline int=A0expand_filer_entries(int begin, int length)
+{
+	int i =3D 0;
+	if (begin < 0 || length <=3D 0 || length + filer_index
+			> MAX_FILER_CACHE_IDX || begin > MAX_FILER_CACHE_IDX)
+		return -EOUTOFRANGE;
+
+	/*Copy*/
+	copy_filer_entries(&(ref->fe[begin + length]), &(ref->fe[begin]),
+			filer_index - length + 1);
+
+	/*Fill up with zeros*/
+	i =3D length;
+	while (i > 0) {
+		ref->fe[i + begin].ctrl =3D 0;
+		ref->fe[i + begin].prop =3D 0;
+		i--;
+	}
+
+	filer_index +=3D length;
+	return 0;
+}
+
+/*Convert a ethtool_rx_ntuple to binary filter format of gianfar*/
+static inline int convert_to_filer(struct ethtool_rx_ntuple_flow_spec =
*rule)
+{
+
+	u32 vlan =3D 0, vlan_mask =3D 0;
+	u32 cfi =3D 0, cfi_mask =3D 0;
+	u32 prio =3D 0, prio_mask =3D 0;
+	u32 id =3D 0, id_mask =3D 0;
+
+	u32 old_index =3D filer_index;
+
+	/*Check if vlan is wanted*/
+	if (rule->vlan_tag !=3D 0 || rule->vlan_tag_mask !=3D 0xFFFF) {
+		if (rule->vlan_tag_mask =3D=3D 0)
+			rule->vlan_tag_mask =3D 0xFFFF;
+
+		vlan =3D RQFPR_VLN;
+		vlan_mask =3D RQFPR_VLN;
+
+		/*Seperate the fields*/
+		cfi =3D (rule->vlan_tag >> 12) & 1;
+		cfi_mask =3D (rule->vlan_tag_mask >> 12) & 1;
+		id =3D rule->vlan_tag & 0xFFF;
+		id_mask =3D rule->vlan_tag_mask & 0xFFF;
+		prio =3D (rule->vlan_tag >> 13) & 0x7;
+		prio_mask =3D (rule->vlan_tag_mask >> 13) & 0x7;
+
+		if (cfi =3D=3D 1 && cfi_mask =3D=3D 1) {
+			vlan |=3D RQFPR_CFI;
+			vlan_mask |=3D RQFPR_CFI;
+		} else if (cfi =3D=3D 0 && cfi_mask =3D=3D 1) {
+			vlan_mask |=3D RQFPR_CFI;
+		}
+	}
+
+	switch (rule->flow_type) {
+	case TCP_V4_FLOW:
+		set_parse_bits(RQFPR_IPV4 | RQFPR_TCP | vlan, RQFPR_IPV4
+				| RQFPR_TCP | vlan_mask);
+		set_basic_ip((struct ethtool_tcpip4_spec *) &rule->h_u,
+				(struct ethtool_tcpip4_spec *) &rule->m_u);
+
+		break;
+	case UDP_V4_FLOW:
+		set_parse_bits(RQFPR_IPV4 | RQFPR_UDP | vlan, RQFPR_IPV4
+				| RQFPR_UDP | vlan_mask);
+		set_basic_ip((struct ethtool_tcpip4_spec *) &rule->h_u,
+				(struct ethtool_tcpip4_spec *) &rule->m_u);
+		break;
+	case SCTP_V4_FLOW:
+		set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask);
+		set_attribute(132, 0xFFFFFFFF, RQFCR_PID_L4P);
+		set_basic_ip((struct ethtool_tcpip4_spec *) &rule->h_u,
+				(struct ethtool_tcpip4_spec *) &rule->m_u);
+		break;
+	case IP_USER_FLOW:
+		set_parse_bits(RQFPR_IPV4 | vlan, RQFPR_IPV4 | vlan_mask);
+		set_user_ip((struct ethtool_usrip4_spec *) &rule->h_u,
+				(struct ethtool_usrip4_spec *) &rule->m_u);
+		break;
+	case ETHER_FLOW:
+		if (vlan !=3D 0)
+			set_parse_bits(vlan, vlan_mask);
+
+		set_ether((struct ethhdr *) &rule->h_u,
+				(struct ethhdr *) &rule->m_u);
+		break;
+	default:
+		return -1;
+	}
+
+	/*Set the vlan attributes in the end*/
+	if (vlan !=3D 0) {
+		set_attribute(0x80000000 | id, 0xFFFFF000 | id_mask,
+				RQFCR_PID_VID);
+		set_attribute(0x80000000 | prio, 0xFFFFFFF8 | prio_mask,
+				RQFCR_PID_PRI);
+	}
+
+	/*If there has been nothing written till now, it must be a default*/
+	if (filer_index =3D=3D old_index) {
+		set_mask(0xFFFFFFFF);
+		ref->fe[filer_index].ctrl =3D 0x20;
+		ref->fe[filer_index].prop =3D 0x0;
+		filer_index++;
+	}
+
+	/*Remove last AND*/
+	ref->fe[filer_index - 1].ctrl =3D ref->fe[filer_index - 1].ctrl
+			& (~RQFCR_AND);
+
+	/*Specify which queue to use or to drop*/
+	if (rule->action =3D=3D ETHTOOL_RXNTUPLE_ACTION_DROP)
+		ref->fe[filer_index - 1].ctrl |=3D RQFCR_RJE;
+	else
+		ref->fe[filer_index - 1].ctrl |=3D (rule->action << 10);
+
+	/*Only big enough entries can be clustered*/
+	if (old_index + 2 < filer_index) {
+		ref->fe[old_index + 1].ctrl |=3D RQFCR_CLE;
+		ref->fe[filer_index - 1].ctrl |=3D RQFCR_CLE;
+	}
+
+	if (filer_index > MAX_FILER_CACHE_IDX - 1)
+		return -ESWFULL;
+
+	return 0;
+
+}
+
+/*Synchronizes the bitpattern from software buffers to hardware regist=
ers*/
+static int write_filer_to_hw(struct gfar_private *priv)
+{
+	s32 i =3D 0;
+	if (filer_index > MAX_FILER_IDX - 1)
+		return -EHWFULL;
+
+	/*Avoid inconsistent filer table*/
+	lock_rx_qs(priv);
+
+	for (; i < MAX_FILER_IDX - 1; i++)
+		gfar_write_filer(priv, i, ref->fe[i].ctrl, ref->fe[i].prop);
+
+	/*Last entry must be default accept
+	 * because that is what people expect*/
+	gfar_write_filer(priv, i, 0x20, 0x0);
+
+	unlock_rx_qs(priv);
+
+	return 0;
+}
+
+/*Fill table with fall-troughs*/
+static inline void init_hw(void)
+{
+	int i =3D 0;
+
+	for (i =3D 0; i < MAX_FILER_CACHE_IDX; i++) {
+		ref->fe[i].ctrl =3D 0x60;
+		ref->fe[i].prop =3D 0xFFFFFFFF;
+	}
+}
+
+int add_table_entry(struct ethtool_rx_ntuple_flow_spec *flow)
+{
+	struct ethtool_rx_ntuple_flow_spec_container *temp;
+	temp =3D kmalloc(sizeof(struct ethtool_rx_ntuple_flow_spec_container)=
,
+			GFP_KERNEL);
+	if (temp =3D=3D NULL)
+		return -ENOMEM;
+	memcpy(&temp->fs, flow, sizeof(struct ethtool_rx_ntuple_flow_spec));
+	list_add_tail(&temp->list, &queue->ntuple_list.list);
+	queue->ntuple_list.count++;
+
+	if ((flow->data !=3D 0) || (flow->data_mask !=3D ~0))
+		printk(KERN_WARNING "User-data is not supported!\n");
+	if (flow->flow_type =3D=3D IP_USER_FLOW)
+		if ((flow->h_u.usr_ip4_spec.ip_ver !=3D 0)
+				|| (flow->m_u.usr_ip4_spec.ip_ver !=3D 255))
+			printk(KERN_WARNING "IP-Version is not supported!\n");
+	if (flow->flow_type =3D=3D ETHER_FLOW)
+		if ((is_broadcast_ether_addr(flow->h_u.ether_spec.h_dest)
+				&& is_zero_ether_addr(
+						flow->m_u.ether_spec.h_dest)))
+			printk(KERN_DEBUG
+			"Filtering broadcast is very cheap!\n");
+
+	return 0;
+
+}
+/*Compares flow-specs a and b and returns 0 if their are the same*/
+static int compare_flow_spec(struct ethtool_rx_ntuple_flow_spec *a,
+		struct ethtool_rx_ntuple_flow_spec *b)
+{
+
+	if (a =3D=3D 0 || b =3D=3D 0)
+		return -1;
+	/*if(ref->fe[i].fs->action!=3Db->action) goto next ;*/
+	/*if(ref->fe[i].fs->data!=3Db->data) goto next ;*/
+	/*if(ref->fe[i].fs->data_mask!=3Db->data_mask) goto next ;*/
+	if (a->flow_type !=3D b->flow_type)
+		return 1;
+	if (a->vlan_tag !=3D b->vlan_tag)
+		return 1;
+	if (a->vlan_tag_mask !=3D b->vlan_tag_mask)
+		return 1;
+	switch (a->flow_type) {
+	case TCP_V4_FLOW:
+	case UDP_V4_FLOW:
+	case SCTP_V4_FLOW:
+		if (a->h_u.tcp_ip4_spec.ip4dst !=3D b->h_u.tcp_ip4_spec.ip4dst)
+			return 1;
+		if (a->h_u.tcp_ip4_spec.ip4src !=3D b->h_u.tcp_ip4_spec.ip4src)
+			return 1;
+		if (a->h_u.tcp_ip4_spec.pdst !=3D b->h_u.tcp_ip4_spec.pdst)
+			return 1;
+		if (a->h_u.tcp_ip4_spec.psrc !=3D b->h_u.tcp_ip4_spec.psrc)
+			return 1;
+		if (a->h_u.tcp_ip4_spec.tos !=3D b->h_u.tcp_ip4_spec.tos)
+			return 1;
+		if (a->m_u.tcp_ip4_spec.ip4dst !=3D b->m_u.tcp_ip4_spec.ip4dst)
+			return 1;
+		if (a->m_u.tcp_ip4_spec.ip4src !=3D b->m_u.tcp_ip4_spec.ip4src)
+			return 1;
+		if (a->m_u.tcp_ip4_spec.pdst !=3D b->m_u.tcp_ip4_spec.pdst)
+			return 1;
+		if (a->m_u.tcp_ip4_spec.psrc !=3D b->m_u.tcp_ip4_spec.psrc)
+			return 1;
+		if (a->m_u.tcp_ip4_spec.tos !=3D b->m_u.tcp_ip4_spec.tos)
+			return 1;
+		break;
+	case IP_USER_FLOW:
+		if (a->h_u.usr_ip4_spec.ip4dst !=3D b->h_u.usr_ip4_spec.ip4dst)
+			return 1;
+		if (a->h_u.usr_ip4_spec.ip4src !=3D b->h_u.usr_ip4_spec.ip4src)
+			return 1;
+		if (a->h_u.usr_ip4_spec.proto !=3D b->h_u.usr_ip4_spec.proto)
+			return 1;
+		if (a->h_u.usr_ip4_spec.ip_ver !=3D b->h_u.usr_ip4_spec.ip_ver)
+			return 1;
+		if (a->h_u.usr_ip4_spec.tos !=3D b->h_u.usr_ip4_spec.tos)
+			return 1;
+		if (a->h_u.usr_ip4_spec.l4_4_bytes
+				!=3D b->h_u.usr_ip4_spec.l4_4_bytes)
+			return 1;
+		if (a->m_u.usr_ip4_spec.ip4dst !=3D b->m_u.usr_ip4_spec.ip4dst)
+			return 1;
+		if (a->m_u.usr_ip4_spec.ip4src !=3D b->m_u.usr_ip4_spec.ip4src)
+			return 1;
+		if (a->m_u.usr_ip4_spec.proto !=3D b->m_u.usr_ip4_spec.proto)
+			return 1;
+		if (a->m_u.usr_ip4_spec.ip_ver !=3D b->m_u.usr_ip4_spec.ip_ver)
+			return 1;
+		if (a->m_u.usr_ip4_spec.tos !=3D b->m_u.usr_ip4_spec.tos)
+			return 1;
+		if (a->m_u.usr_ip4_spec.l4_4_bytes
+				!=3D b->m_u.usr_ip4_spec.l4_4_bytes)
+			return 1;
+		break;
+	case AH_V4_FLOW:
+	case ESP_V4_FLOW:
+		if (a->h_u.ah_ip4_spec.ip4dst !=3D b->h_u.ah_ip4_spec.ip4dst)
+			return 1;
+		if (a->h_u.ah_ip4_spec.ip4src !=3D b->h_u.ah_ip4_spec.ip4src)
+			return 1;
+		if (a->h_u.ah_ip4_spec.spi !=3D b->h_u.ah_ip4_spec.spi)
+			return 1;
+		if (a->h_u.ah_ip4_spec.tos !=3D b->h_u.ah_ip4_spec.tos)
+			return 1;
+		if (a->m_u.ah_ip4_spec.ip4dst !=3D b->m_u.ah_ip4_spec.ip4dst)
+			return 1;
+		if (a->m_u.ah_ip4_spec.ip4src !=3D b->m_u.ah_ip4_spec.ip4src)
+			return 1;
+		if (a->m_u.ah_ip4_spec.spi !=3D b->m_u.ah_ip4_spec.spi)
+			return 1;
+		if (a->m_u.ah_ip4_spec.tos !=3D b->m_u.ah_ip4_spec.tos)
+			return 1;
+		break;
+	case ETHER_FLOW:
+		if (compare_ether_addr(a->h_u.ether_spec.h_dest,
+				b->h_u.ether_spec.h_dest))
+			return 1;
+		if (compare_ether_addr(a->h_u.ether_spec.h_source,
+				b->h_u.ether_spec.h_source))
+			return 1;
+		if (compare_ether_addr(a->m_u.ether_spec.h_dest,
+				b->m_u.ether_spec.h_dest))
+			return 1;
+		if (compare_ether_addr(a->m_u.ether_spec.h_source,
+				b->m_u.ether_spec.h_source))
+			return 1;
+		if (a->h_u.ether_spec.h_proto !=3D b->h_u.ether_spec.h_proto)
+			return 1;
+		if (a->m_u.ether_spec.h_proto !=3D b->m_u.ether_spec.h_proto)
+			return 1;
+		break;
+	default:
+		return 1;
+	}
+
+	return 0;
+}
+
+/*Searches the existing flow_specs for flow and return NULL if none fo=
und
+ * or the address of the container in the linked list in case of succe=
ss*/
+struct ethtool_rx_ntuple_flow_spec_container *search_table_entry(
+		struct ethtool_rx_ntuple_flow_spec *flow)
+{
+	struct ethtool_rx_ntuple_flow_spec_container *loop;
+	list_for_each_entry(loop, &queue->ntuple_list.list, list) {
+		if (compare_flow_spec(flow, &loop->fs) =3D=3D 0)
+			return loop;
+	}
+	return NULL;
+}
+
+int del_table_entry(struct ethtool_rx_ntuple_flow_spec_container *cont=
)
+{
+
+	kfree(&cont->fs);
+
+	list_del(&cont->list);
+
+	queue->ntuple_list.count--;
+
+	return 0;
+}
+
+static inline int get_next_cluster_start(int start)
+{
+	for (; (start < filer_index) && (start < MAX_FILER_CACHE_IDX - 1);
+	 start++) {
+		if ((ref->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE))
+				=3D=3D (RQFCR_AND | RQFCR_CLE)) {
+			return start;
+		}
+	}
+	return -1;
+}
+
+static inline int get_next_cluster_end(int start)
+{
+	for (; (start < filer_index) && (start < MAX_FILER_CACHE_IDX - 1);
+	 start++) {
+		if ((ref->fe[start].ctrl & (RQFCR_AND | RQFCR_CLE))
+				=3D=3D (RQFCR_CLE))
+			return start;
+	}
+	return -1;
+}
+
+/*Uses hardwares clustering option to reduce
+* the number of filer table entries*/
+static inline void cluster(void)
+{
+	s32 i =3D -1, j, iend, jend;
+	/*Do regular clustering*/
+	while ((i =3D get_next_cluster_start(++i)) !=3D -1) {
+		j =3D i;
+		while ((j =3D get_next_cluster_start(++j)) !=3D -1) {
+			if (ref->fe[i].ctrl !=3D ref->fe[j].ctrl)
+				break;
+			if (ref->fe[i].prop !=3D ref->fe[j].prop)
+				break;
+			if (ref->fe[i - 1].ctrl !=3D ref->fe[j - 1].ctrl)
+				break;
+			if (ref->fe[i - 1].prop !=3D ref->fe[j - 1].prop)
+				break;
+			/*If we come here i and j are
+			*candidates for clustering!*/
+			iend =3D get_next_cluster_end(i);
+			jend =3D get_next_cluster_end(j);
+			if (jend =3D=3D -1 || iend =3D=3D -1)
+				break;
+			/*First we make some free space, where our cluster
+			* element should be. Then we copy it there and finally
+			* delete in from its old location.
+			 */
+
+			if (expand_filer_entries(iend, (jend - j))
+					=3D=3D -EOUTOFRANGE)
+				break;
+
+			copy_filer_entries(&(ref->fe[iend + 1]), &(ref->fe[jend
+					+ 1]), jend - j);
+
+			if (trim_filer_entries(jend - 1, jend + (jend - j))
+					=3D=3D -EOUTOFRANGE)
+				return;
+
+			/*Mask out cluster bit*/
+			ref->fe[iend].ctrl &=3D ~(RQFCR_CLE);
+
+		}
+	}
+}
+
+/*Swaps the 0xFF80 masked bits of a1<>a2 and b1<>b2*/
+static inline void swap_ff80_bits(struct filer_entry *a1,
+		struct filer_entry *a2, struct filer_entry *b1,
+		struct filer_entry *b2)
+{
+
+	u32 temp[4];
+	temp[0] =3D a1->ctrl & 0xFF80;
+	temp[1] =3D a2->ctrl & 0xFF80;
+	temp[2] =3D b1->ctrl & 0xFF80;
+	temp[3] =3D b2->ctrl & 0xFF80;
+
+	a1->ctrl &=3D ~0xFF80;
+	a2->ctrl &=3D ~0xFF80;
+	b1->ctrl &=3D ~0xFF80;
+	b2->ctrl &=3D ~0xFF80;
+
+	a1->ctrl |=3D temp[1];
+	a2->ctrl |=3D temp[0];
+	b1->ctrl |=3D temp[3];
+	b2->ctrl |=3D temp[2];
+
+}
+
+/*Reduces the number of masks needed in the filer table to save entrie=
s*/
+static int optimize_masks(void)
+{
+
+	struct filer_table *dubli;
+
+	struct and_entry *and_table;
+
+	u32 and_index =3D 0, block_index =3D 1, previous_mask =3D 0, i =3D 0,=
 j =3D 0,
+			size =3D 0, start =3D 0, prev =3D 1;
+
+	u32 old_first, old_last, new_first, new_last;
+
+	s32 ret =3D 0;
+
+	/*We need a copy of the filer table because
+	* we want to change its order*/
+	dubli =3D kmalloc(sizeof(struct filer_table), GFP_KERNEL);
+	if (dubli =3D=3D NULL)
+		return -ENOMEM;
+	memcpy(dubli, ref, sizeof(struct filer_table));
+
+	and_table =3D kzalloc(sizeof(struct and_entry)
+			* (MAX_FILER_CACHE_IDX / 2 + 1), GFP_KERNEL);
+	if (and_table =3D=3D NULL) {
+		ret =3D -ENOMEM;
+		goto end;
+	}
+
+	/*Make a list consisting of masks values with their start and
+	* end of validity and block as idicator for parts belonging
+	* together (glued by ANDs)*/
+	for (i =3D 0; i < filer_index; i++) {
+
+		if ((ref->fe[i].ctrl & 0xF) =3D=3D 0) {
+			and_table[and_index].mask =3D ref->fe[i].prop;
+			and_table[and_index].start =3D i;
+			and_table[and_index].block =3D block_index;
+			if (and_index >=3D 1)
+				and_table[and_index - 1].end =3D i - 1;
+			and_index++;
+		}
+		/*Cluster starts will be seperated because they should
+		* hold their position*/
+		if ((ref->fe[i].ctrl & RQFCR_CLE) =3D=3D RQFCR_CLE)
+			block_index++;
+		/*A not set AND indicated the end of a depended block*/
+		if ((ref->fe[i].ctrl & RQFCR_AND) =3D=3D 0)
+			block_index++;
+
+	}
+
+	and_table[and_index - 1].end =3D i - 1;
+
+	/*Now we can sort the table from above by the values of the masks.
+	* Important: The 0xFF80 flags of the first and last entry of a
+	* block must hold their position (which queue, CLE, RJE, AND)*/
+	for (i =3D 0; i < and_index; i++) {
+
+		if (prev !=3D and_table[i].block) {
+			old_first =3D and_table[start].start + 1;
+			old_last =3D and_table[i - 1].end;
+			/*I my opinion start should be multiplied by
+			* sizeof(struct and_entry) do not ask me why
+			* only this version is working */
+			sort(and_table + start, size, sizeof(struct and_entry),
+					&my_comp, &my_swap);
+			/*Toggle order for every block. This makes the
+			* thing more efficient! Believe me!*/
+
+			toggle_order();
+
+			new_first =3D and_table[start].start + 1;
+			new_last =3D and_table[i - 1].end;
+
+			/*Thats the 0xFF80 swapping*/
+			swap_ff80_bits(&dubli->fe[new_first],
+					&dubli->fe[old_first],
+					&dubli->fe[new_last],
+					&dubli->fe[old_last]);
+
+			start =3D i;
+			size =3D 0;
+		}
+		size++;
+		prev =3D and_table[i].block;
+	}
+
+	/*Now we can copy the data from our duplicated filer table to
+	* the real one in the order the mask table says*/
+	for (i =3D 0; i < and_index; i++) {
+		size =3D and_table[i].end - and_table[i].start + 1;
+		copy_filer_entries(&(ref->fe[j]),
+				&(dubli->fe[and_table[i].start]), size);
+		j +=3D size;
+	}
+
+	/*Silly duplicate checker: Drops identical masks*/
+
+	for (i =3D 0; i < filer_index && i < MAX_FILER_CACHE_IDX; i++) {
+		if (ref->fe[i].ctrl =3D=3D 0x80) {
+			previous_mask =3D i++;
+			break;
+		}
+	}
+	for (; i < filer_index && i < MAX_FILER_CACHE_IDX; i++) {
+		if (ref->fe[i].ctrl =3D=3D 0x80) {
+			if (ref->fe[i].prop =3D=3D ref->fe[previous_mask].prop) {
+				/*Two identical ones found!
+				* So drop the second one!*/
+				trim_filer_entries(i, i);
+
+			} else
+				/*Not identical!*/
+				previous_mask =3D i;
+		}
+	}
+
+	kfree(and_table);
+end:	kfree(dubli);
+	return ret;
+}
+
+int do_action(struct ethtool_rx_ntuple_flow_spec *flow,
+		struct gfar_private *priv)
+{
+	struct ethtool_rx_ntuple_flow_spec_container *loop_ptr;
+	s32 i =3D 0;
+	s32 ret =3D 0;
+	filer_index =3D 0;
+
+	/*Only temporary needed! The 20 additional
+	* entries are a shadow for one element*/
+	ref =3D kzalloc(sizeof(struct filer_table) + 20
+			* sizeof(struct filer_table), GFP_KERNEL);
+	if (ref =3D=3D NULL) {
+		printk(KERN_WARNING "Can not get memory\n");
+		return -ENOMEM;
+	}
+
+	loop_ptr =3D search_table_entry(flow);
+
+	if (flow->action =3D=3D ETHTOOL_RXNTUPLE_ACTION_CLEAR) {
+		if (loop_ptr !=3D NULL)
+			del_table_entry(loop_ptr);
+		else {
+			printk(KERN_WARNING "Element not found!\n");
+			return -1;
+		}
+	} else {
+		if (loop_ptr !=3D NULL) {
+			printk(KERN_WARNING "Element is already online!\n");
+			return -1;
+		}
+
+	}
+
+	/*Initializes the filer table with a default accept for all packets*/
+	init_hw();
+
+	/*Now convert the existing filer data from flow_spec into
+	* filer tables binary format*/
+	list_for_each_entry(loop_ptr, &queue->ntuple_list.list, list) {
+		ret =3D convert_to_filer(&loop_ptr->fs);
+		if (ret =3D=3D -ESWFULL) {
+			printk(KERN_WARNING
+			"To much entries! Can not add! SW\n");
+			goto end;
+		}
+	}
+
+	/*Here add the new one*/
+	if (flow->action !=3D ETHTOOL_RXNTUPLE_ACTION_CLEAR) {
+		ret =3D convert_to_filer(flow);
+		if (ret =3D=3D -ESWFULL) {
+			printk(KERN_WARNING
+			"To much entries! Can not add! SW\n");
+			goto end;
+		}
+		if (ret =3D=3D -1) {
+			printk(KERN_WARNING "Flow-type not supported!\n");
+			goto end;
+		}
+	}
+
+	i =3D filer_index;
+
+	/*Optimizations to save entries*/
+	cluster();
+	optimize_masks();
+
+	printk(KERN_DEBUG "\tSummary:\n"
+	"\tData on hardware: %d\n"
+	"\tCompression rate: %d %%\n", filer_index, 100 - (100 * filer_index)
+			/ i);
+
+	/*Write everything to hardware*/
+	ret =3D write_filer_to_hw(priv);
+	if (ret =3D=3D -EHWFULL) {
+		printk(KERN_WARNING "To much entries! Can not add! HW\n");
+		goto end;
+	}
+
+	/*Only if all worked fine, add the flow*/
+	if (flow->action !=3D ETHTOOL_RXNTUPLE_ACTION_CLEAR)
+		add_table_entry(flow);
+
+end:	kfree(ref);
+	return ret;
+}
+
+static struct interf *init_table(struct gfar_private *priv)
+{
+	struct gfar __iomem *regs =3D NULL;
+	int i;
+
+	regs =3D priv->gfargrp[0].regs;
+
+	/*Check if we are in FIFO mode*/
+	i =3D gfar_read(&regs->ecntrl);
+	i &=3D ECNTRL_FIFM;
+	if (i =3D=3D ECNTRL_FIFM) {
+		i =3D gfar_read(&regs->rctrl);
+		i &=3D RCTRL_PRSDEP_MASK | RCTRL_PRSFM;
+		if (i =3D=3D (RCTRL_PRSDEP_MASK | RCTRL_PRSFM)) {
+			printk(KERN_EMERG
+			"Interface in FIFO mode\n"
+			"Receive Queue Filtering enabled\n");
+		} else {
+			printk(KERN_EMERG
+			"Interface in FIFO mode\n"
+			"Receive Queue Filtering is disabled\n");
+			return (struct interf *)-1;
+		}
+	}
+	/*Or in standard mode*/
+	else{
+		i =3D gfar_read(&regs->rctrl);
+		i &=3D RCTRL_PRSDEP_MASK;
+		if (i =3D=3D RCTRL_PRSDEP_MASK) {
+			printk(KERN_EMERG
+			"Receive Queue Filtering enabled\n");
+		} else {
+			printk(KERN_EMERG
+			"Receive Queue Filtering is disabled\n");
+			return (struct interf *)-1;
+		}
+	}
+
+	/*Sets the properties for arbitrary filer rule
+	* to the first 4 Layer 4 Bytes*/
+	regs->rbifx =3D 0xC0C1C2C3;
+
+	queue =3D kzalloc(sizeof(struct interf), GFP_KERNEL);
+	INIT_LIST_HEAD(&(queue->ntuple_list.list));
+	queue->ntuple_list.count =3D 0;
+
+	return queue;
+
+}
+
+static int gfar_set_rx_ntuple(struct net_device *dev,
+		struct ethtool_rx_ntuple *cmd)
+{	struct gfar __iomem *regs =3D NULL;
+	struct gfar_private *priv =3D netdev_priv(dev);
+	int i =3D 0;
+	static struct interf *store[10];
+
+	regs =3D priv->gfargrp[0].regs;
+
+	/*Only values between -2 and num_rx_queues -1 allowed*/
+	if ((cmd->fs.action >=3D (signed int)priv->num_rx_queues) ||
+	(cmd->fs.action < ETHTOOL_RXNTUPLE_ACTION_CLEAR))
+		return -EINVAL;
+
+	for (i =3D 0; i < 10; i++) {
+		if (store[i] =3D=3D 0) {
+			store[i] =3D init_table(priv);
+			if (store[i] =3D=3D (struct interf *)-1) {
+				store[i] =3D 0;
+				return -1;
+			}
+			strcpy(store[i]->name, dev->name);
+			break;
+		} else if (!strcmp(store[i]->name, dev->name)) {
+			queue =3D store[i];
+			break;
+		}
+
+	}
+
+	do_action(&cmd->fs, priv);
+
+	return 0;
+}
+
+
=A0const struct ethtool_ops gfar_ethtool_ops =3D {
=A0	.get_settings =3D gfar_gsettings,
=A0	.set_settings =3D gfar_ssettings,
@@ -808,4 +1815,6 @@ const struct ethtool_ops gfar_ethtool_op
=A0	.set_wol =3D gfar_set_wol,
=A0#endif
=A0	.set_rxnfc =3D gfar_set_nfc,
+	/*function for accessing rx queue filer*/
+	.set_rx_ntuple =3D gfar_set_rx_ntuple
=A0};
=A0
Signed-off-by: Sebastian Poehn <sebastian.poehn@belden.com>
DISCLAIMER:

Privileged and/or Confidential information may be contained in this
message. If you are not the addressee of this message, you may not
copy, use or deliver this message to anyone. In such event, you
should destroy the message and kindly notify the sender by reply
e-mail. It is understood that opinions or conclusions that do not
relate to the official business of the company are neither given
nor endorsed by the company.

Thank You.

