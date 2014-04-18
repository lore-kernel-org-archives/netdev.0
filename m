From: Michael Maier <m1278468-KKof4HMRyILR7s880joybQ@public.gmane.org>
Subject: Re: Kernel crash in bridge module: unable to handle
 kernel paging request
Date: Fri, 18 Apr 2014 20:10:39 +0200
Message-ID: <53516A9F.9070309@allmail.net>
References: <20140417110002.790f7ae1@dualc.maya.org>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------050604090800020408050903"
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org" <users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>,
	"linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
In-Reply-To: <20140417110002.790f7ae1-lvhFbKb8wlWhKFOg3t/3XQ@public.gmane.org>
List-Unsubscribe: <http://rt2x00.serialmonkey.com/mailman/options/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=unsubscribe>
List-Archive: <http://rt2x00.serialmonkey.com/pipermail/users_rt2x00.serialmonkey.com/>
List-Post: <mailto:users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Help: <mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=help>
List-Subscribe: <http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com>,
	<mailto:users-request-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org?subject=subscribe>
Errors-To: users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
Sender: "users" <users-bounces-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050604090800020408050903
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Michael Maier wrote:
> Hello!
> 
> I'm using the following configuration on CentOS 6.5 w/ lt-kernel
> (3.10.37) - or any other kernel version.
> 
> brctl addbr br0
> brctl addif br0 eth0
> 
> ip li add vxlan0 type vxlan id 1 group 239.1.1.1 ttl 1 dev ra0
> 
> brctl addif br0 vxlan0
> 
> This is one end of a vxlan tunnel via WLAN.
> 
> At the moment the first package arrives the bridge, the 64 bit-kernel
> crashes (32 bit kernel works perfectly). What could be the reason for
> the crash w/ 64 bit kernel? Btw: there isn't any problem even w/ 64
> bit kernel as long as the bridge code isn't involved.

The rt5572sta driver (DPO_RT5572_LinuxSTA_2.6.1.3_20121022) isn't
completely 64 bit stable. The attached patch makes rt5572sta working
with 64bit kernels even when used with a bridge like mentioned above.

The patch is derived from
https://github.com/ashaffer/rt3573sta/commit/2654eaee416f238a6651465c88a804ee251afe74
- there it was applied to rt3573 driver from Ralink / Mediatek.

I applied and tested it for rt5572sta (which is the newer one and
supports a lot more chips, amongst others rt3573) and kernel 3.13.6 / 64
bit. I suppose it to work with 3.10.x, too.


I detected, that bridging does not work with 3.14.x - but there is no
crash - it just doesn't work (packages came in in eth0, go through the
bridge and vxlan, are remotely answered, but the sent response can only
be seen in the vxlan and br0 device - but it can't be seen in eth0 -
strange).



Michael

--------------050604090800020408050903
Content-Type: text/x-patch;
 name="ralink-64bit-1.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ralink-64bit-1.diff"

diff --git a/include/os/rt_linux.h b/include/os/rt_linux.h
index 1612e34..c3a7792 100644
--- a/include/os/rt_linux.h
+++ b/include/os/rt_linux.h
@@ -858,9 +858,14 @@ void linux_pci_unmap_single(void *handle, ra_dma_addr_t dma_addr, size_t size, i
 		
 #define GET_OS_PKT_DATATAIL(_pkt) \
 		(RTPKT_TO_OSPKT(_pkt)->tail)
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+#define SET_OS_PKT_DATATAIL(_pkt, _start, _len)	\
+		((RTPKT_TO_OSPKT(_pkt))->tail) = (PUCHAR)(RTPKT_TO_OSPKT(_pkt)->data-(RTPKT_TO_OSPKT(_pkt)->head) + (_len))
+#else
 #define SET_OS_PKT_DATATAIL(_pkt, _start, _len)	\
 		((RTPKT_TO_OSPKT(_pkt))->tail) = (PUCHAR)((_start) + (_len))
-		
+#endif
+
 #define GET_OS_PKT_HEAD(_pkt) \
 		(RTPKT_TO_OSPKT(_pkt)->head)
 
diff --git a/os/linux/rt_linux.c b/os/linux/rt_linux.c
index f5b5e19..817bca8 100644
--- a/os/linux/rt_linux.c
+++ b/os/linux/rt_linux.c
@@ -505,9 +505,15 @@ PNDIS_PACKET duplicate_pkt(
 		MEM_DBG_PKT_ALLOC_INC(skb);
 
 		skb_reserve(skb, 2);
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+		NdisMoveMemory(skb->data+skb->tail, pHeader802_3, HdrLen);
+		skb_put(skb, HdrLen);
+		NdisMoveMemory(skb->data+skb->tail, pData, DataSize);
+#else
 		NdisMoveMemory(skb->tail, pHeader802_3, HdrLen);
 		skb_put(skb, HdrLen);
 		NdisMoveMemory(skb->tail, pData, DataSize);
+#endif
 		skb_put(skb, DataSize);
 		skb->dev = pNetDev;	/*get_netdev_from_bssid(pAd, FromWhichBSSID); */
 		pPacket = OSPKT_TO_RTPKT(skb);
@@ -705,7 +711,11 @@ void wlan_802_11_to_802_3_packet(
 	pOSPkt->dev = pNetDev;
 	pOSPkt->data = pData;
 	pOSPkt->len = DataSize;
+#ifdef NET_SKBUFF_DATA_USES_OFFSET
+	pOSPkt->tail = (pOSPkt->data-pOSPkt->head)+pOSPkt->len;
+#else
 	pOSPkt->tail = pOSPkt->data + pOSPkt->len;
+#endif
 
 	/* */
 	/* copy 802.3 header */

--------------050604090800020408050903
Content-Type: text/x-patch;
 name="ralink-64bit-2.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
 filename="ralink-64bit-2.diff"

diff --git a/include/os/rt_linux.h b/include/os/rt_linux.h
index c3a7792..f5975a1 100644
--- a/include/os/rt_linux.h
+++ b/include/os/rt_linux.h
@@ -860,7 +860,7 @@ void linux_pci_unmap_single(void *handle, ra_dma_addr_t dma_addr, size_t size, i
 		(RTPKT_TO_OSPKT(_pkt)->tail)
 #ifdef NET_SKBUFF_DATA_USES_OFFSET
 #define SET_OS_PKT_DATATAIL(_pkt, _start, _len)	\
-		((RTPKT_TO_OSPKT(_pkt))->tail) = (PUCHAR)(RTPKT_TO_OSPKT(_pkt)->data-(RTPKT_TO_OSPKT(_pkt)->head) + (_len))
+		((RTPKT_TO_OSPKT(_pkt))->tail) = (ULONG)RTPKT_TO_OSPKT(_pkt)->data - (ULONG)(RTPKT_TO_OSPKT(_pkt)->head) + (_len)
 #else
 #define SET_OS_PKT_DATATAIL(_pkt, _start, _len)	\
 		((RTPKT_TO_OSPKT(_pkt))->tail) = (PUCHAR)((_start) + (_len))

--------------050604090800020408050903
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
users mailing list
users-poMEt7QlJxcwIE2E9O76wjtx2kNaKg5H@public.gmane.org
http://rt2x00.serialmonkey.com/mailman/listinfo/users_rt2x00.serialmonkey.com

--------------050604090800020408050903--
