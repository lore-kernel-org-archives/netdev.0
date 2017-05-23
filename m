From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net PATCH] mlx5: fix bug reading rss_hash_type from CQE
Date: Tue, 23 May 2017 16:41:09 +0300
Message-ID: <CALzJLG_UjC4FSFyOYzvHpepj_Hnx6zFda5vsEQEnMieTWYQuyA@mail.gmail.com>
References: <149547678696.10455.14428063974882319686.stgit@firesoul>
 <CALzJLG9sAw3_-jL9R3=g6pZ517NMVRrFFya0E+NE5jUMH_uu8w@mail.gmail.com> <20170523150420.770f6c4e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Saeed Mahameed <saeedm@mellanox.com>,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f195.google.com ([209.85.216.195]:34693 "EHLO
        mail-qt0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967814AbdEWNla (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 09:41:30 -0400
Received: by mail-qt0-f195.google.com with SMTP id l39so22255303qtb.1
        for <netdev@vger.kernel.org>; Tue, 23 May 2017 06:41:30 -0700 (PDT)
In-Reply-To: <20170523150420.770f6c4e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 23, 2017 at 4:04 PM, Jesper Dangaard Brouer
<brouer@redhat.com> wrote:
> On Tue, 23 May 2017 13:58:44 +0300
> Saeed Mahameed <saeedm@dev.mellanox.co.il> wrote:
>
>> On Mon, May 22, 2017 at 9:13 PM, Jesper Dangaard Brouer
>> <brouer@redhat.com> wrote:
>> > Masks for extracting part of the Completion Queue Entry (CQE)
>> > field rss_hash_type was swapped, namely CQE_RSS_HTYPE_IP and
>> > CQE_RSS_HTYPE_L4.
>> >
>> > The bug resulted in setting skb->l4_hash, even-though the
>> > rss_hash_type indicated that hash was NOT computed over the
>> > L4 (UDP or TCP) part of the packet.
>> >
>> > Added comments from the datasheet, to make it more clear what
>> > these masks are selecting.
>> >
>> > Signed-off-by: Jesper Dangaard Brouer <brouer@redhat.com>
>> > ---
>> >  include/linux/mlx5/device.h |   10 ++++++++--
>> >  1 file changed, 8 insertions(+), 2 deletions(-)
>> >
>> > diff --git a/include/linux/mlx5/device.h b/include/linux/mlx5/device.h
>> > index dd9a263ed368..a940ec6a046c 100644
>> > --- a/include/linux/mlx5/device.h
>> > +++ b/include/linux/mlx5/device.h
>> > @@ -787,8 +787,14 @@ enum {
>> >  };
>> >
>> >  enum {
>> > -       CQE_RSS_HTYPE_IP        = 0x3 << 6,
>> > -       CQE_RSS_HTYPE_L4        = 0x3 << 2,
>> > +       CQE_RSS_HTYPE_IP        = 0x3 << 2,
>> > +       /* cqe->rss_hash_type[3:2] - IP destination selected for hash
>> > +        * (00 = none,  01 = IPv4, 10 = IPv6, 11 = Reserved)
>> > +        */
>> > +       CQE_RSS_HTYPE_L4        = 0x3 << 6,
>> > +       /* cqe->rss_hash_type[7:6] - L4 destination selected for hash
>> > +        * (00 = none, 01 = TCP. 10 = UDP, 11 = IPSEC.SPI
>> > +        */
>> >  };
>> >
>>
>> Acked-by: Saeed Mahameed <saeedm@mellanox.com>
>>
>> Nice catch Jesper !!
>>
>> Can I ask how did you find the hash was wrong ?
>> any counters/indicators we can look for in internal testing ?
>
> Found this when developing the XDP rxhash RFC patches[1][2].  And I used my
> xdp_rxhash[3] program to inspect the hash values, but I guess that
> doesn't help for internal testing.
>
> [1] http://patchwork.ozlabs.org/patch/764057/
> [2] http://patchwork.ozlabs.org/patch/764060/
> [3] https://github.com/netoptimizer/prototype-kernel/tree/master/kernel/samples/bpf
>
> I also have a trafgen script that generate fake packets, but for your
> purpose you can just use ping.  A standard ICMP ping packet should be
> categorized as
>  CQE_RSS_HTYPE_IP == (IPv4=01) and
>  CQE_RSS_HTYPE_L4 == (none=00).
>
> I was going to recommend using a cls_bpf program to inspect the same,
> but it looks like it doesn't expose the skb->l4_hash bit, which shows
> the bug.
>
> I guess, Alexie would say use kprobes.  I tried, but everything gets
> inlined in the driver.  I did find a reliable inspection point, which
> is napi_gro_receive().
>
> Basically follow my blogpost:
>  http://netoptimizer.blogspot.dk/2016/12/reading-live-runtime-kernel-variables.html
>
> This is how you can verify my patch works with perf probe:
>
>  perf probe -a 'napi_gro_receive hash=skb->hash htype=skb->ooo_okay:u8 skb->dev->name:string'
>
>  perf record -e probe:napi_gro_receive -aR
>  # send traffic
>  perf script # results
>  perf probe -d napi_gro_receive
>

Thanks Jesper, will try that soon.

> Notice (acme), that I had to do an ugly trick: "htype=skb->ooo_okay:u8"
> because perf didn't correctly decode bit the field skb->l4_hash.  Thus,
> I'm type casting "ooo_okay" to u8, and skb->l4_hash is set if htype=2,
> as skb->l4_hash is the second bit in that byte.  Maybe ACME can fix that? ;-)
>
> --
> Best regards,
>   Jesper Dangaard Brouer
>   MSc.CS, Principal Kernel Engineer at Red Hat
>   LinkedIn: http://www.linkedin.com/in/brouer
>
> This is how a ping flood looks like with xdp_rxhash
>
> [jbrouer@skylake prototype-kernel]$ sudo ./xdp_rxhash --dev mlx5p2 --sec 2
>
> xdp-action     pps        pps-human-readable mem
> XDP_ABORTED    0          0                  2.000273  read
> XDP_DROP       0          0                  2.000272  read
> XDP_PASS       95626      95,626             2.000272  read
> XDP_TX         0          0                  2.000272  read
> rx_total       95626      95,626             2.000272  read
>
> hash_type:L3   pps        pps-human-readable sample-period
> Unknown        0          0                  2.000270
> IPv4           95626      95,626             2.000272
> IPv6           0          0                  2.000272
>
> hash_type:L4   pps        pps-human-readable sample-period
> Unknown        95627      95,627             2.000272
> TCP            0          0                  2.000272
> UDP            0          0                  2.000270
>
> ^CInterrupted: Removing XDP program on ifindex:5 device:mlx5p2
