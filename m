From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH 3/5] virtio: Don't expose legacy net features when VIRTIO_NET_NO_LEGACY defined.
Date: Mon, 16 Feb 2015 16:39:42 +1030
Message-ID: <87egpqtmjd.fsf@rustcorp.com.au>
References: <1423199216-2094-1-git-send-email-rusty@rustcorp.com.au> <1423199216-2094-4-git-send-email-rusty@rustcorp.com.au> <20150208105908.GI3185@redhat.com> <87fvag3qv3.fsf@rustcorp.com.au> <87twytb9by.fsf@rustcorp.com.au> <20150216051435.GA14616@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: lkml <linux-kernel@vger.kernel.org>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150216051435.GA14616@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"Michael S. Tsirkin" <mst@redhat.com> writes:
>>  	struct virtio_net_hdr hdr;
>>  	__virtio16 num_buffers;	/* Number of merged rx buffers */
>>  };
>> +#else /* ... VIRTIO_NET_NO_LEGACY */
>> +/*
>> + * This header comes first in the scatter-gather list.  If you don't
>> + * specify GSO or CSUM features, you can simply ignore the header.
>> + *
>> + * This is bitwise-equivalent to the legacy struct virtio_net_hdr_mrg_rxbuf.
>
> I would add "but with all fields squashed into the main structure".

Yep.

>> + */
>> +struct virtio_net_hdr_v1 {
>> +#define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	/* Use csum_start, csum_offset */
>> +#define VIRTIO_NET_HDR_F_DATA_VALID	2	/* Csum is valid */
>> +	__u8 flags;
>> +#define VIRTIO_NET_HDR_GSO_NONE		0	/* Not a GSO frame */
>> +#define VIRTIO_NET_HDR_GSO_TCPV4	1	/* GSO frame, IPv4 TCP (TSO) */
>> +#define VIRTIO_NET_HDR_GSO_UDP		3	/* GSO frame, IPv4 UDP (UFO) */
>> +#define VIRTIO_NET_HDR_GSO_TCPV6	4	/* GSO frame, IPv6 TCP */
>> +#define VIRTIO_NET_HDR_GSO_ECN		0x80	/* TCP has ECN set */
>> +	__u8 gso_type;
>> +	__virtio16 hdr_len;	/* Ethernet + IP + tcp/udp hdrs */
>> +	__virtio16 gso_size;	/* Bytes to append to hdr_len per frame */
>> +	__virtio16 csum_start;	/* Position to start checksumming from */
>> +	__virtio16 csum_offset;	/* Offset after that to place checksum */
>> +	__virtio16 num_buffers;	/* Number of merged rx buffers */
>> +};
>> +#endif /* ...VIRTIO_NET_NO_LEGACY */
>
> I note that this way host code can't be structured like this:
>
>
> 	struct virtio_net_hdr_v1 modern;
> 	/* handle modern guests */
> 	....
>
> #ifndef VIRTIO_NET_NO_LEGACY
> 	struct virtio_net_hdr_mrg_rxbuf mrg;
> 	/* handle legacy guests */
> 	
> #endif
>
>
> Define virtio_net_hdr_v1 unconditionally?

Thanks, that's a good idea!  Here's the incremental:

virtio_net: unconditionally define struct virtio_net_hdr_v1.

This was introduced in commit ed9ecb0415b97b5f9f91f146e1977bb372c74c6d,
but only defined if !VIRTIO_NET_NO_LEGACY.  We should always define
it: easier for users to have conditional legacy code.

Suggested-by: "Michael S. Tsirkin" <mst@redhat.com>
Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>

diff --git a/include/uapi/linux/virtio_net.h b/include/uapi/linux/virtio_net.h
index 4a9b58113d6e..7bbee79ca293 100644
--- a/include/uapi/linux/virtio_net.h
+++ b/include/uapi/linux/virtio_net.h
@@ -74,39 +74,12 @@ struct virtio_net_config {
 	__u16 max_virtqueue_pairs;
 } __attribute__((packed));
 
-#ifndef VIRTIO_NET_NO_LEGACY
-/* This header comes first in the scatter-gather list.
- * For legacy virtio, if VIRTIO_F_ANY_LAYOUT is not negotiated, it must
- * be the first element of the scatter-gather list.  If you don't
- * specify GSO or CSUM features, you can simply ignore the header. */
-struct virtio_net_hdr {
-#define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	// Use csum_start, csum_offset
-#define VIRTIO_NET_HDR_F_DATA_VALID	2	// Csum is valid
-	__u8 flags;
-#define VIRTIO_NET_HDR_GSO_NONE		0	// Not a GSO frame
-#define VIRTIO_NET_HDR_GSO_TCPV4	1	// GSO frame, IPv4 TCP (TSO)
-#define VIRTIO_NET_HDR_GSO_UDP		3	// GSO frame, IPv4 UDP (UFO)
-#define VIRTIO_NET_HDR_GSO_TCPV6	4	// GSO frame, IPv6 TCP
-#define VIRTIO_NET_HDR_GSO_ECN		0x80	// TCP has ECN set
-	__u8 gso_type;
-	__virtio16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
-	__virtio16 gso_size;		/* Bytes to append to hdr_len per frame */
-	__virtio16 csum_start;	/* Position to start checksumming from */
-	__virtio16 csum_offset;	/* Offset after that to place checksum */
-};
-
-/* This is the version of the header to use when the MRG_RXBUF
- * feature has been negotiated. */
-struct virtio_net_hdr_mrg_rxbuf {
-	struct virtio_net_hdr hdr;
-	__virtio16 num_buffers;	/* Number of merged rx buffers */
-};
-#else /* ... VIRTIO_NET_NO_LEGACY */
 /*
  * This header comes first in the scatter-gather list.  If you don't
  * specify GSO or CSUM features, you can simply ignore the header.
  *
- * This is bitwise-equivalent to the legacy struct virtio_net_hdr_mrg_rxbuf.
+ * This is bitwise-equivalent to the legacy struct virtio_net_hdr_mrg_rxbuf,
+ * only flattened.
  */
 struct virtio_net_hdr_v1 {
 #define VIRTIO_NET_HDR_F_NEEDS_CSUM	1	/* Use csum_start, csum_offset */
@@ -124,6 +97,29 @@ struct virtio_net_hdr_v1 {
 	__virtio16 csum_offset;	/* Offset after that to place checksum */
 	__virtio16 num_buffers;	/* Number of merged rx buffers */
 };
+
+#ifndef VIRTIO_NET_NO_LEGACY
+/* This header comes first in the scatter-gather list.
+ * For legacy virtio, if VIRTIO_F_ANY_LAYOUT is not negotiated, it must
+ * be the first element of the scatter-gather list.  If you don't
+ * specify GSO or CSUM features, you can simply ignore the header. */
+struct virtio_net_hdr {
+	/* See VIRTIO_NET_HDR_F_* */
+	__u8 flags;
+	/* See VIRTIO_NET_HDR_GSO_* */
+	__u8 gso_type;
+	__virtio16 hdr_len;		/* Ethernet + IP + tcp/udp hdrs */
+	__virtio16 gso_size;		/* Bytes to append to hdr_len per frame */
+	__virtio16 csum_start;	/* Position to start checksumming from */
+	__virtio16 csum_offset;	/* Offset after that to place checksum */
+};
+
+/* This is the version of the header to use when the MRG_RXBUF
+ * feature has been negotiated. */
+struct virtio_net_hdr_mrg_rxbuf {
+	struct virtio_net_hdr hdr;
+	__virtio16 num_buffers;	/* Number of merged rx buffers */
+};
 #endif /* ...VIRTIO_NET_NO_LEGACY */
 
 /*
