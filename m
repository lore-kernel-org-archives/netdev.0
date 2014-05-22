From: Iyappan Subramanian <isubramanian@apm.com>
Subject: Re: [PATCH v4 0/4] net: Add APM X-Gene SoC Ethernet driver support
Date: Thu, 22 May 2014 00:41:24 -0700
Message-ID: <CAKh23Fne5Ea0BBXtudoUXRW1ijH17NbEfYPJx_UiKSaiwnSRUw@mail.gmail.com>
References: <1399326447-2329-1-git-send-email-isubramanian@apm.com>
	<CACVXFVPRcPxm2a+-VDa=80Xp3w+p_+k0ng=7B9KyP8r3E=4_YA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Network Development <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"jcm@redhat.com" <jcm@redhat.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	patches <patches@apm.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Keyur Chudgar <kchudgar@apm.com>,
	linux-arm-kernel <linux-arm-kernel@lists.infradead.org>,
	Ravi Patel <rapatel@apm.com>
To: Ming Lei <ming.lei@canonical.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod5og115.obsmtp.com ([64.18.0.246]:56404 "HELO
	exprod5og115.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1750909AbaEVHl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 May 2014 03:41:26 -0400
Received: by mail-la0-f53.google.com with SMTP id ty20so785547lab.26
        for <netdev@vger.kernel.org>; Thu, 22 May 2014 00:41:24 -0700 (PDT)
In-Reply-To: <CACVXFVPRcPxm2a+-VDa=80Xp3w+p_+k0ng=7B9KyP8r3E=4_YA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 12, 2014 at 9:24 PM, Ming Lei <ming.lei@canonical.com> wrote:
> Hi Iyappan,
>
> On Tue, May 6, 2014 at 5:47 AM, Iyappan Subramanian
> <isubramanian@apm.com> wrote:
>> Adding APM X-Gene SoC Ethernet driver.
>>
>> v4: Address comments from v3 review
>> * MAINTAINERS: changed status to supported
>> * Kconfig: made default to no
>> * changed to bool data type wherever applicable
>> * cleaned up single bit set and masking code
>> * removed statistics counters masking
>> * removed unnecessary OOM message printing
>> * fixed dma_map_single and dma_unmap_single size parameter
>> * changed set bits macro body using new set_bits function
>
> I just tested the v4 against 3.15.0-rc5-next-20140512+ on mustang
> board , looks ethernet becomes very unstable with the change,
> sometimes I saw:
>
> [  301.057140] Unable to handle kernel paging request at virtual
> address ffffffc800a7cd70
>
> Also network may  become unusable after a while from booting.

As Mark pointed out, missing spin_lock_init(&pdata->stats_lock) is
causing kernel crash.

The network instability is due to default DMA ops have made non-coherent.
Plesae refer to https://lkml.org/lkml/2014/5/4/27

Default DMA ops changed to non-coherent to preserve compatibility with
  32-bit ARM DT files. The "dma-coherent" property can be used to
  explicitly mark a device coherent.



>
> Another oops log found during reboot:
>
> [ 1156.315992] skbuff: skb_over_panic: text:ffffffc000435b48 len:1514
> put:1514 head:          (null) data:ffffffc3ec667dd0 tail:0x5ea
> end:0x0 dev:<NULL>
> [ 1156.329322] BUG: failure at net/core/skbuff.c:99/skb_panic()!
> [ 1156.335043] Kernel panic - not syncing: BUG!
> [ 1156.339292] CPU: 3 PID: 2710 Comm: ip Not tainted
> 3.15.0-rc5-next-20140512+ #29
> [ 1156.346562] Call trace:
> [ 1156.349000] [<ffffffc000087884>] dump_backtrace+0x0/0x10c
> [ 1156.354372] [<ffffffc0000879a0>] show_stack+0x10/0x1c
> [ 1156.359398] [<ffffffc000625b50>] dump_stack+0x88/0xcc
> [ 1156.364422] [<ffffffc0006219dc>] panic+0xe4/0x228
> [ 1156.369101] [<ffffffc000626574>] skb_panic+0x78/0x7c
> [ 1156.374041] [<ffffffc0004a3e98>] skb_put+0x7c/0x8c
> [ 1156.378807] [<ffffffc000435b44>] xgene_enet_process_ring+0xcc/0x2b4
> [ 1156.385041] [<ffffffc000435e2c>] xgene_enet_close+0xb0/0xd8
> [ 1156.390583] [<ffffffc0004ad11c>] __dev_close_many+0xa0/0xd0
> [ 1156.396126] [<ffffffc0004ad170>] __dev_close+0x24/0x40
> [ 1156.401237] [<ffffffc0004b3c94>] __dev_change_flags+0xa4/0x14c
> [ 1156.407039] [<ffffffc0004b3d58>] dev_change_flags+0x1c/0x5c
> [ 1156.412582] [<ffffffc0004c046c>] do_setlink+0x250/0x6ec
> [ 1156.417779] [<ffffffc0004c1590>] rtnl_newlink+0x320/0x508
> [ 1156.423149] [<ffffffc0004c18f8>] rtnetlink_rcv_msg+0x180/0x1a0
> [ 1156.428952] [<ffffffc0004d5558>] netlink_rcv_skb+0x60/0xc4
> [ 1156.434408] [<ffffffc0004c00c4>] rtnetlink_rcv+0x1c/0x2c
> [ 1156.439692] [<ffffffc0004d4c8c>] netlink_unicast+0xcc/0x18c
> [ 1156.445234] [<ffffffc0004d5374>] netlink_sendmsg+0x57c/0x5f8
> [ 1156.450863] [<ffffffc0004992f4>] sock_sendmsg+0x68/0x84
> [ 1156.456060] [<ffffffc000499bc0>] ___sys_sendmsg+0x1ec/0x288
> [ 1156.461602] [<ffffffc00049c9cc>] __sys_sendmsg+0x3c/0x64
> [ 1156.466886] [<ffffffc00049ca00>] SyS_sendmsg+0xc/0x20
>
>
>
> Thanks
> --
> Ming Lei
