From: Michele Baldessari <michele@acksyn.org>
Subject: Re: [PATCHv2] vhost-net: fix use-after-free in vhost_net_flush
Date: Wed, 3 Jul 2013 08:55:35 +0200
Message-ID: <20130703065535.GA2748@marquez.int.rhx>
References: <20130625142946.GA17414@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	"David S. Miller" <davem@davemloft.net>
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
In-Reply-To: <20130625142946.GA17414@redhat.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 25, 2013 at 05:29:46PM +0300, Michael S. Tsirkin wrote:
> vhost_net_ubuf_put_and_wait has a confusing name:
> it will actually also free it's argument.
> Thus since commit 1280c27f8e29acf4af2da914e80ec27c3dbd5c01
>     "vhost-net: flush outstanding DMAs on memory change"
> vhost_net_flush tries to use the argument after passing it
> to vhost_net_ubuf_put_and_wait, this results
> in use after free.
> To fix, don't free the argument in vhost_net_ubuf_put_and_wait,
> add an new API for callers that want to free ubufs.

This patch (slightly tweaked to apply it to 3.10.0) fixes the following
backtrace for me:

    [exception RIP: vhost_poll_queue+10]
    RIP: ffffffffa05d5baa  RSP: ffff88013fa83c78  RFLAGS: 00010286
    RAX: 00000000c23988bd  RBX: ffff88011f504200  RCX: 0000000000000003
    RDX: 0000000000000000  RSI: 00000000000000c0  RDI: 0000000000000080
    RBP: ffff88013fa83ca8   R8: ffffea0000dc1ba0   R9: 000000000009f414
    R10: 00000000000040b4  R11: 0000000000000000  R12: ffff88011ddb0000
    R13: 0000000000000000  R14: 0000000000000000  R15: ffff88011dcf5a00
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018
 #9 [ffff88013fa83c80] vhost_zerocopy_callback at ffffffffa05d8dac [vhost_net]
#10 [ffff88013fa83cb0] skb_copy_ubufs at ffffffff8152e0cd
#11 [ffff88013fa83d10] skb_clone at ffffffff8152e214
#12 [ffff88013fa83d30] deliver_clone at ffffffffa05840f5 [bridge]
#13 [ffff88013fa83d58] br_flood at ffffffffa05846ad [bridge]
#14 [ffff88013fa83da0] br_flood_forward at ffffffffa0584875 [bridge]
#15 [ffff88013fa83db0] br_handle_frame_finish at ffffffffa0585514 [bridge]
#16 [ffff88013fa83df0] br_handle_frame at ffffffffa0585825 [bridge]
#17 [ffff88013fa83e28] __netif_receive_skb_core at ffffffff8153b522
#18 [ffff88013fa83e80] __netif_receive_skb at ffffffff8153bae8
#19 [ffff88013fa83ea0] process_backlog at ffffffff8153c61e
#20 [ffff88013fa83ee8] net_rx_action at ffffffff8153bed9
#21 [ffff88013fa83f40] __do_softirq at ffffffff81064997
#22 [ffff88013fa83fb0] call_softirq at ffffffff81651adc
--- <IRQ stack> ---
#23 [ffff88011ea27ca0] netif_rx at ffffffff8153ad99
#24 [ffff88011ea27cd8] netif_rx_ni at ffffffff8153b218
#25 [ffff88011ea27cf0] tun_get_user at ffffffffa05a78ff [tun]
#26 [ffff88011ea27d80] tun_sendmsg at ffffffffa05a7d27 [tun]
#27 [ffff88011ea27da0] handle_tx at ffffffffa05d8830 [vhost_net]
#28 [ffff88011ea27e60] handle_tx_kick at ffffffffa05d8c55 [vhost_net]
#29 [ffff88011ea27e70] vhost_worker at ffffffffa05d578d [vhost_net]
#30 [ffff88011ea27ed0] kthread at ffffffff81080ba0
#31 [ffff88011ea27f50] ret_from_fork at ffffffff8165066c
    [exception RIP: unknown or invalid address]
    RIP: 0000000000000000  RSP: ffff88011ea27f58  RFLAGS: 00000202
    RAX: 0000000000000000  RBX: ffffffff81080ae0  RCX: 0000000000000000
    RDX: 0000000000000000  RSI: 0000000000000000  RDI: 0000000000000000
    RBP: ffff8801371cfcf8   R8: 0000000000000000   R9: 0000000000000000
    R10: 0000000000000000  R11: 0000000000000000  R12: 0000000000000000
    R13: 0000000000000000  R14: 0000000000000000  R15: 0000000000000000
    ORIG_RAX: ffffffffffffffff  CS: 0010  SS: 0018

Feel free to add when you resubmit to net:
Tested-by: Michele Baldessari <michele@acksyn.org>
-- 
Michele Baldessari            <michele@acksyn.org>
C2A5 9DA3 9961 4FFB E01B  D0BC DDD4 DCCB 7515 5C6D
