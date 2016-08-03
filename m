From: Vegard Nossum <vegard.nossum@oracle.com>
Subject: Re: [PATCH] 9p/trans_virtio: use kvfree() for
 iov_iter_get_pages_alloc()
Date: Wed, 3 Aug 2016 11:32:33 +0200
Message-ID: <57A1BA31.8030502@oracle.com>
References: <1469185929-476-1-git-send-email-vegard.nossum@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	v9fs-developer@lists.sourceforge.net, linux-kernel@vger.kernel.org,
	netdev <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: Eric Van Hensbergen <ericvh@gmail.com>,
	Ron Minnich <rminnich@sandia.gov>,
	Latchesar Ionkov <lucho@ionkov.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1469185929-476-1-git-send-email-vegard.nossum@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 07/22/2016 01:12 PM, Vegard Nossum wrote:
> The memory allocated by iov_iter_get_pages_alloc() can be allocated with
> vmalloc() if kmalloc() failed -- see get_pages_array().
>
> In that case we need to free it with vfree(), so let's use kvfree().
>
> The bug manifests like this:
>
> BUG: unable to handle kernel paging request at ffffeb0400072da0
> IP: [<ffffffff8139c67b>] kfree+0x4b/0x140
> PGD 0
> Oops: 0000 [#1] PREEMPT SMP KASAN
> CPU: 2 PID: 675 Comm: trinity-c2 Not tainted 4.7.0-rc7+ #14
> Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS Ubuntu-1.8.2-1ubuntu1 04/01/2014
> task: ffff8800badef2c0 ti: ffff880069208000 task.ti: ffff880069208000
> RIP: 0010:[<ffffffff8139c67b>]  [<ffffffff8139c67b>] kfree+0x4b/0x140
> RSP: 0000:ffff88006920f3f0  EFLAGS: 00010282
> RAX: ffffea0000000000 RBX: ffffc90001cb6000 RCX: 0000000000000000
> RDX: 0000000000000001 RSI: 0000000000000246 RDI: ffffc90001cb6000
> RBP: ffff88006920f410 R08: 0000000000000000 R09: dffffc0000000000
> R10: ffff8800badefa30 R11: 0000056a3d3b0d9f R12: ffff88006920f620
> R13: ffffeb0400072d80 R14: ffff8800baa94078 R15: 0000000000000000
> FS:  00007fbd2b437700(0000) GS:ffff88011af00000(0000) knlGS:0000000000000000
> CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
> CR2: ffffeb0400072da0 CR3: 000000006926d000 CR4: 00000000000006e0
> Stack:
>   0000000000000001 ffff88006920f620 ffffed001755280f ffff8800baa94078
>   ffff88006920f6a8 ffffffff8310442b dffffc0000000000 ffff8800badefa30
>   ffff8800badefa28 ffff88011af1fba0 1ffff1000d241e98 ffff8800ba892150
> Call Trace:
>   [<ffffffff8310442b>] p9_virtio_zc_request+0x72b/0xdb0
>   [<ffffffff830f2116>] p9_client_zc_rpc.constprop.8+0x246/0xb10
>   [<ffffffff830f5d79>] p9_client_read+0x4c9/0x750
>   [<ffffffff8175ceac>] v9fs_fid_readpage+0x14c/0x320
>   [<ffffffff8175d0b6>] v9fs_vfs_readpage+0x36/0x50
>   [<ffffffff812c6f13>] filemap_fault+0x9a3/0xe60
>   [<ffffffff81331878>] __do_fault+0x158/0x300
>   [<ffffffff81339e01>] handle_mm_fault+0x1cf1/0x3c80
>   [<ffffffff810c0aaa>] __do_page_fault+0x30a/0x8e0
>   [<ffffffff810c10df>] do_page_fault+0x2f/0x80
>   [<ffffffff810b5b07>] do_async_page_fault+0x27/0xa0
>   [<ffffffff83296c48>] async_page_fault+0x28/0x30
> Code: 00 80 41 54 53 49 01 fd 48 0f 42 05 b0 39 67 02 48 89 fb 49 01 c5 48 b8 00 00 00 00 00 ea ff ff 49 c1 ed 0c 49 c1 e5 06 49 01 c5 <49> 8b 45 20 48 8d 50 ff a8 01 4c 0f 45 ea 49 8b 55 20 48 8d 42
> RIP  [<ffffffff8139c67b>] kfree+0x4b/0x140
>   RSP <ffff88006920f3f0>
> CR2: ffffeb0400072da0
> ---[ end trace f3d59a04bafec038 ]---
>
> Cc: Al Viro <viro@zeniv.linux.org.uk>
> Signed-off-by: Vegard Nossum <vegard.nossum@oracle.com>
> ---
>   net/9p/trans_virtio.c | 4 ++--
>   1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/net/9p/trans_virtio.c b/net/9p/trans_virtio.c
> index 4acb1d5..f24b25c 100644
> --- a/net/9p/trans_virtio.c
> +++ b/net/9p/trans_virtio.c
> @@ -507,8 +507,8 @@ err_out:
>   		/* wakeup anybody waiting for slots to pin pages */
>   		wake_up(&vp_wq);
>   	}
> -	kfree(in_pages);
> -	kfree(out_pages);
> +	kvfree(in_pages);
> +	kvfree(out_pages);
>   	return err;
>   }
>
>

Ping? Should this go to somebody else? Added a couple of Ccs.


Vegard
