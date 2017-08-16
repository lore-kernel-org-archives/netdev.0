From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next V2 1/3] tap: use build_skb() for small packet
Date: Wed, 16 Aug 2017 03:24:44 -0700
Message-ID: <1502879084.4936.95.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1502451678-17358-1-git-send-email-jasowang@redhat.com>
         <1502451678-17358-2-git-send-email-jasowang@redhat.com>
         <1502855120.4936.89.camel@edumazet-glaptop3.roam.corp.google.com>
         <2ae570ab-01da-2ea2-0549-3e310158b817@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, mst@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kubakici@wp.pl
To: Jason Wang <jasowang@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <2ae570ab-01da-2ea2-0549-3e310158b817@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2017-08-16 at 11:55 +0800, Jason Wang wrote:
> 
> On 2017年08月16日 11:45, Eric Dumazet wrote:
> >
> > You do realize that tun_build_skb() is not thread safe ?
> 
> Ok, I think the issue if skb_page_frag_refill(), need a spinlock 
> probably. Will prepare a patch.

But since tun is used from process context, why don't you use the
per-thread generator (no lock involved)

tcp_sendmsg() uses this for GFP_KERNEL allocations.

Untested patch :

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5892284eb8d05b0678d820bad3d0d2c61a879aeb..c38cd840cc0b7fecf182b23976e36f709cacca1f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -175,7 +175,6 @@ struct tun_file {
 	struct list_head next;
 	struct tun_struct *detached;
 	struct skb_array tx_array;
-	struct page_frag alloc_frag;
 };
 
 struct tun_flow_entry {
@@ -578,8 +577,6 @@ static void __tun_detach(struct tun_file *tfile, bool clean)
 		}
 		if (tun)
 			skb_array_cleanup(&tfile->tx_array);
-		if (tfile->alloc_frag.page)
-			put_page(tfile->alloc_frag.page);
 		sock_put(&tfile->sk);
 	}
 }
@@ -1272,7 +1269,7 @@ static struct sk_buff *tun_build_skb(struct tun_struct *tun,
 				     struct virtio_net_hdr *hdr,
 				     int len, int *generic_xdp)
 {
-	struct page_frag *alloc_frag = &tfile->alloc_frag;
+	struct page_frag *alloc_frag = &current->task_frag;
 	struct sk_buff *skb;
 	struct bpf_prog *xdp_prog;
 	int buflen = SKB_DATA_ALIGN(len + TUN_RX_PAD) +
@@ -2580,8 +2577,6 @@ static int tun_chr_open(struct inode *inode, struct file * file)
 	tfile->sk.sk_write_space = tun_sock_write_space;
 	tfile->sk.sk_sndbuf = INT_MAX;
 
-	tfile->alloc_frag.page = NULL;
-
 	file->private_data = tfile;
 	INIT_LIST_HEAD(&tfile->next);
 
