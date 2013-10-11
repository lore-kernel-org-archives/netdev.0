From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 1/2 ] {xfrm, sctp} Stick to software crc32 even if hardware
 is capable of that
Date: Fri, 11 Oct 2013 15:05:45 +0800
Message-ID: <5257A349.3010605@windriver.com>
References: <1381384296-1821-1-git-send-email-fan.du@windriver.com> <20131010131116.GA16147@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: Neil Horman <nhorman@tuxdriver.com>, <vyasevich@gmail.com>,
	<steffen.klassert@secunet.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:64843 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752335Ab3JKHGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 03:06:45 -0400
In-Reply-To: <20131010131116.GA16147@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2013=E5=B9=B410=E6=9C=8810=E6=97=A5 21:11, Neil Horman wrote:
> On Thu, Oct 10, 2013 at 01:51:36PM +0800, Fan Du wrote:
>> igb/ixgbe have hardware sctp checksum support, when this feature is =
enabled
>> and also IPsec is armed to protect sctp traffic, ugly things happene=
d as
>> xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum ev=
ery thing
>> up and pack the 16bits result in the checksum field). The result is =
fail
>> establishment of sctp communication.
>>
> Shouldn't this be fixed in the xfrm code then?  E.g. check the device=
 features
> for SCTP checksum offloading and and skip the checksum during xfrm ou=
tput if its
> available?
>
> Or am I missing something?
> Neil
>
>


 From 014276de0877f11d46e1704114a7d91f19221a63 Mon Sep 17 00:00:00 2001
=46rom: Fan Du <fan.du@windriver.com>
Date: Fri, 11 Oct 2013 14:24:33 +0800
Subject: [PATCH 1/2] {xfrm, sctp} Stick to software crc32 even if hardw=
are is
  capable of that

igb/ixgbe have hardware sctp checksum support, when this feature is ena=
bled
and also IPsec is armed to protect sctp traffic, ugly things happened a=
s
xfrm_output checks CHECKSUM_PARTIAL to do check sum operation(sum every=
 thing
up and pack the 16bits result in the checksum field). The result is fai=
l
establishment of sctp communication.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
v2:
   Leave ip_summed as CHECKSUM_PARTIAL as before, the second patch will=
 fix this.

---
  net/sctp/output.c |   14 +++++++++++++-
  1 file changed, 13 insertions(+), 1 deletion(-)

diff --git a/net/sctp/output.c b/net/sctp/output.c
index 0ac3a65..6de6402 100644
--- a/net/sctp/output.c
+++ b/net/sctp/output.c
@@ -372,6 +372,16 @@ static void sctp_packet_set_owner_w(struct sk_buff=
 *skb, struct sock *sk)
  	atomic_inc(&sk->sk_wmem_alloc);
  }

+static int is_xfrm_armed(struct dst_entry *dst)
+{
+#ifdef CONFIG_XFRM
+	/* If dst->xfrm is valid, this skb needs to be transformed */
+	return dst->xfrm !=3D NULL;
+#else
+	return 0;
+#endif
+}
+
  /* All packets are sent to the network through this function from
   * sctp_outq_tail().
   *
@@ -536,7 +546,9 @@ int sctp_packet_transmit(struct sctp_packet *packet=
)
  	 * by CRC32-C as described in <draft-ietf-tsvwg-sctpcsum-02.txt>.
  	 */
  	if (!sctp_checksum_disable) {
-		if (!(dst->dev->features & NETIF_F_SCTP_CSUM)) {
+		if ((!(dst->dev->features & NETIF_F_SCTP_CSUM)) ||
+			is_xfrm_armed(dst)) {
+
  			__u32 crc32 =3D sctp_start_cksum((__u8 *)sh, cksum_buf_len);

  			/* 3) Put the resultant value into the checksum field in the
--=20
1.7.9.5




--=20
=E6=B5=AE=E6=B2=89=E9=9A=8F=E6=B5=AA=E5=8F=AA=E8=AE=B0=E4=BB=8A=E6=9C=9D=
=E7=AC=91

--fan
