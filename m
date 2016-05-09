From: Dexuan Cui <decui@microsoft.com>
Subject: RE: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
Date: Mon, 9 May 2016 15:27:46 +0000
Message-ID: <BN3PR03MB1416297C0F5733413AA0F11BBF700@BN3PR03MB1416.namprd03.prod.outlook.com>
References: <BLUPR03MB1410F30AED34632F8F1268DEBF7E0@BLUPR03MB1410.namprd03.prod.outlook.com>
	<20160507.134048.139772599380708393.davem@davemloft.net>
	<BLUPR03MB141044B2FC50DE43401C8C17BF7F0@BLUPR03MB1410.namprd03.prod.outlook.com>
 <20160508.134500.680661474744275849.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devel@linuxdriverproject.org" <devel@linuxdriverproject.org>,
	"olaf@aepfle.de" <olaf@aepfle.de>,
	"apw@canonical.com" <apw@canonical.com>,
	"jasowang@redhat.com" <jasowang@redhat.com>,
	"cavery@redhat.com" <cavery@redhat.com>,
	KY Srinivasan <kys@microsoft.com>,
	Haiyang Zhang <haiyangz@microsoft.com>,
	"joe@perches.com" <joe@perches.com>,
	"vkuznets@redhat.com" <vkuznets@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160508.134500.680661474744275849.davem@davemloft.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> From: David Miller [mailto:davem@davemloft.net]
> Sent: Monday, May 9, 2016 1:45
> To: Dexuan Cui <decui@microsoft.com>
> Cc: gregkh@linuxfoundation.org; netdev@vger.kernel.org; linux-
> kernel@vger.kernel.org; devel@linuxdriverproject.org; olaf@aepfle.de;
> apw@canonical.com; jasowang@redhat.com; cavery@redhat.com; KY
> Srinivasan <kys@microsoft.com>; Haiyang Zhang <haiyangz@microsoft.com>;
> joe@perches.com; vkuznets@redhat.com
> Subject: Re: [PATCH v9 net-next 1/2] hv_sock: introduce Hyper-V Sockets
>
> From: Dexuan Cui <decui@microsoft.com>
> Date: Sun, 8 May 2016 06:11:04 +0000
>
> > Thanks for pointing this out!
> > I understand, so I think I should add a module parameter, e.g.,
> > "hv_sock.max_socket_number" with a default value, say, 1024?
>
> No, you should get rid of the huge multi-page buffers.

Hi David,
Ok, how do you like the below proof-of-concept patch snippet?

I use 1 page for the recv buf and another page for send buf. They should be
allocated by kmalloc(sizeof(struct hvsock_send/recv_buf), GFP_KERNEL).

And, by default, I use 2 pages for VMBUS send/recv ringbuffers respectively.
(Note: 2 is the minimal ringbuffer size because actually 1 page of the two is used
as the shared read/write index etc, rather than data)
A module parameter will be added to allow the user to use a big ringbuffer
size, if the user cares too much about the performance.

Another parameter will be added to limit how many hvsock sockets can be
created at most. The default value can be 1024, meaning at most
1024 * (2+2+1+1) * 4KB = 24MB memory is used.

-#define VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV (5 * PAGE_SIZE)
-#define VMBUS_RINGBUFFER_SIZE_HVSOCK_SEND (5 * PAGE_SIZE)
+#define VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV (2 * PAGE_SIZE)
+#define VMBUS_RINGBUFFER_SIZE_HVSOCK_SEND (2 * PAGE_SIZE)

-#define HVSOCK_RCV_BUF_SZ      VMBUS_RINGBUFFER_SIZE_HVSOCK_RECV
+#define HVSOCK_RCV_BUF_SZ      PAGE_SIZE
 #define HVSOCK_SND_BUF_SZ      PAGE_SIZE

+struct hvsock_send_buf {
+       struct vmpipe_proto_header hdr;
+       u8 buf[HVSOCK_SND_BUF_SZ];
+};
+
+struct hvsock_recv_buf {
+       struct vmpipe_proto_header hdr;
+       u8 buf[HVSOCK_RCV_BUF_SZ];
+
+       unsigned int data_len;
+       unsigned int data_offset;
+};
+
@@ -35,21 +48,8 @@ struct hvsock_sock {

        struct vmbus_channel *channel;

-       struct {
-               struct vmpipe_proto_header hdr;
-               u8 buf[HVSOCK_SND_BUF_SZ];
-       } send;
-
-       struct {
-               struct vmpipe_proto_header hdr;
-               u8 buf[HVSOCK_RCV_BUF_SZ];
-
-               unsigned int data_len;
-               unsigned int data_offset;
-       } recv;
+       struct hvsock_send_buf *send_buf;
+       struct hvsock_recv_buf *recv_buf;
 };

Thanks,
-- Dexuan
