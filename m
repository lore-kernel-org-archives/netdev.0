From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net-next 08/14] mlx4: use order-0 pages for RX
Date: Mon, 13 Feb 2017 16:46:15 -0800
Message-ID: <1487033175.8227.37.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170213195858.5215-1-edumazet@google.com>
         <20170213195858.5215-9-edumazet@google.com>
         <CAKgT0Ufx0Y=9kjLax36Gx4e7Y-A7sKZDNYxgJ9wbCT4_vxHhGA@mail.gmail.com>
         <CANn89iLkPB_Dx1L2dFfwOoeXOmPhu_C3OO2yqZi8+Rvjr=-EtA@mail.gmail.com>
         <CAKgT0UeB_e_Z7LM1_r=en8JJdgLhoYFstWpCDQN6iawLYZJKDA@mail.gmail.com>
         <CANn89iJfLu8ai1SDGDt5aowAGibdxumDA89Y44f6SjTTt+sGBg@mail.gmail.com>
         <CAKgT0UdgnKzJ8PJFPfvJiOSZQ3E3Sw5nWjyrROuERv0=-dxmxQ@mail.gmail.com>
         <CANn89iLgUsPDL0wbuHk5RaehzJ+TRLQ=WkVBMTB65scrEjO3Ug@mail.gmail.com>
         <CAKgT0Uex--jLtBtJ+wp8wmkZuUfTu7ktYTvBF9623Ztm_NrGxw@mail.gmail.com>
         <CANn89iJ+kn4ycP2HV_um5JUfPWpX9KJ0KFtXyx3562c=kCBYyQ@mail.gmail.com>
         <CAKgT0Uf-JhOn+OOyjO8GH5SepA68j36eSY2m-buWJ5AH_82o2g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Tariq Toukan <tariqt@mellanox.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Willem de Bruijn <willemb@google.com>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        Brenden Blanco <bblanco@plumgrid.com>,
        Alexei Starovoitov <ast@kernel.org>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ot0-f194.google.com ([74.125.82.194]:35504 "EHLO
        mail-ot0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751743AbdBNAqS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 19:46:18 -0500
Received: by mail-ot0-f194.google.com with SMTP id 65so14269870otq.2
        for <netdev@vger.kernel.org>; Mon, 13 Feb 2017 16:46:17 -0800 (PST)
In-Reply-To: <CAKgT0Uf-JhOn+OOyjO8GH5SepA68j36eSY2m-buWJ5AH_82o2g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-02-13 at 16:34 -0800, Alexander Duyck wrote:
> On Mon, Feb 13, 2017 at 4:22 PM, Eric Dumazet <edumazet@google.com> wrote:
> > On Mon, Feb 13, 2017 at 3:47 PM, Alexander Duyck
> > <alexander.duyck@gmail.com> wrote:
> >
> >> Actually it depends on the use case.  In the case of pktgen packets
> >> they are usually dropped pretty early in the receive path.  Think
> >> something more along the lines of a TCP syn flood versus something
> >> that would be loading up a socket.
> >
> > So I gave another spin an it, reducing the MTU on the sender to 500
> > instead of 1500 to triple the load (in term of packets per second)
> > since the sender seems to hit some kind of limit around 30Gbit.
> >
> > Number of packets we process on one RX queue , and one TCP flow.
> >
> > Current patch series : 6.3 Mpps
> >
> > Which is not too bad ;)
> >
> > This number does not change putting your __page_frag_cache_drain() trick.
> 
> Well the __page_frag_cache_drain by itself isn't going to add much of
> anything.  You really aren't going to be using it except for in the
> slow path.  I was talking about the bulk page count update by itself.
> All __page_frag_cache_drain gets you is it cleans up the
> page_frag_sub(n-1); put_page(1); code calls.
> 
> The approach I took for the Intel drivers isn't too different than
> what we did for the skbuff page frag cache.  Basically I update the
> page count once every 65535 frames setting it to 64K, and holding no
> more than 65535 references in the pagecnt_bias.  Also in my code I
> don't update the count until after the first recycle call since the
> highest likelihood of us discarding the frame is after the first
> allocation anyway so we wait until the first recycle to start
> repopulating the count.

Alex, be assured that I implemented the full thing, of course.

( The pagecnt_bias field, .. refilled every 16K rounds )

And I repeat : I got _no_ convincing results to justify this patch being
sent in this series.

This series is not about adding 1% or 2% performance changes, but adding
robustness to RX allocations.


 
