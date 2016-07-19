From: Brenden Blanco <bblanco@plumgrid.com>
Subject: Re: [PATCH v8 06/11] net/mlx4_en: add page recycle to prepare rx
 ring for tx support
Date: Tue, 19 Jul 2016 10:41:32 -0700
Message-ID: <20160719174130.GA19547@gmail.com>
References: <1468309894-26258-1-git-send-email-bblanco@plumgrid.com>
 <1468309894-26258-7-git-send-email-bblanco@plumgrid.com>
 <20160712.141832.634796503160544753.davem@davemloft.net>
 <20160713005424.GB13865@gmail.com>
 <3d0c7f78-0647-e927-94dd-76cbe4ddcb28@gmail.com>
 <20160713154058.GA3320@gmail.com>
 <20160715215242.GA980@gmail.com>
 <6d638467-eea6-d3e1-6984-88a1198ef303@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	jhs@mojatatu.com, saeedm@dev.mellanox.co.il, kafai@fb.com,
	brouer@redhat.com, as754m@att.com, alexei.starovoitov@gmail.com,
	gerlitz.or@gmail.com, john.fastabend@gmail.com,
	hannes@stressinduktion.org, tgraf@suug.ch, tom@herbertland.com,
	daniel@iogearbox.net
To: Tariq Toukan <ttoukan.linux@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f174.google.com ([209.85.192.174]:35346 "EHLO
	mail-pf0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951AbcGSRlh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jul 2016 13:41:37 -0400
Received: by mail-pf0-f174.google.com with SMTP id x72so9426671pfd.2
        for <netdev@vger.kernel.org>; Tue, 19 Jul 2016 10:41:37 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <6d638467-eea6-d3e1-6984-88a1198ef303@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 19, 2016 at 04:33:28PM +0300, Tariq Toukan wrote:
[...]
> >So, I took Dave's suggestion to heart, and spent the last 2 days seeing
> >what was possible to implement with just xdp as the focus, rather than
> >an overall cleanup which Tariq will be looking at.
> >
> >Unfortunately, this turned out to a be a bit of a rat hole.
> >
> >What I wanted to do was to pre-allocate all the required pages before
> >reaching the point of no return. Doing this isn't all that hard, since
> >it should just be a few loops. However, I ended with a bit more
> >duplicated code than one would like, since I had to tease out the
> >various sections that assume exclusive access to hardware.
> >
> >But, more than that, is that I don't see a way to fill these pages into
> >the rings safely while hardware still has ability to write into the old
> >ones. There was no "pause" API that I could find besides
> >mlx4_en_stop_port(). That function is fairly destructive and requires
> >the resource allocation in mlx4_en_start_port() to succeed to recover
> >the port status.
> >
> >One option that I considered would be to drain buffers from the rx ring,
> >and just let mlx4_en_recover_from_oom() do its job once we update the
> >page template in frag_info[]. This, however, also requires the queues to
> >be paused safely, so we again have to rely on mlx4_en_stop_port().
> >
> >One change I can make is to avoid allocating additional tx rings, which
> >means that we can skip the calls to mlx4_en_free/alloc_resources().
> I think it's more natural to manage the two types of tx rings
> without converting one type to the other dynamically, just to avoid
> re-allocation.
> I don't see the re-allocation of resources as a serious issue here,
> especially after I submitted patches that add resiliency and make it
> more safe (see them in [1]).
Yes, I saw those, it would be helpful for the v8 version but with v9
onwards I guess it is not conflicting, since no reallocation is done.
> We just need to make sure we don't end up with an inoperative port,
> I will take care of it once net and net-next are merged.
Thanks
> 
> I'd like to keep the tx rings separation, also when it comes to
> resource allocation, so that we allocate xdp rings when needed, and
> not borrow them from the other type.
> I have two possible solutions in mind:
> 1) Based on the suggestion you have in v8, in which rsv tx rings
> grow beyond to the regular tx array, while maintaining the
> accounting.
> One improvement to make the code more clear and readable is to
> explicitly define two fields for accounting the number of tx rings:
> - rename rsv_tx_rings to xdp_tx_rings.
I'll incorporate this one, since anyway the code is changing a bit to
accommodate prog-per-ring.
> - have a new priv->netdev_num_tx_rings = priv->num_tx_rings - xdp_tx_rings.
> and then modify driver rings iterators accordingly.
The ring iteration is sprinkled in too many places to incorporate
easily, so this makes sense as its own cleanup, with either (1) or (2)
from your proposal.
> 
> 2) Another solution I have in mind goes as follows.
> Expand the current tx_ring array to be two dimensional, where
> tx_ring[0] points to the regular tx array, and tx_ring[1] points to
> the xdp rings.
> We look to keep using the same napi handlers and not get into code
> duplication, and make minimal adjustments that do not harm
> performance.
> The idea is to mark CQ's types in creation time, so that we know for
> each CQ whether it's for a regular TX ring or an XDP tx ring.
> When we get a completion, we can just read the CQ type, and then
> choose the correct tx_ring according to cq type and cq->ring,
> something like tx_ring[cq->cq_type][cq->ring]; (we can do it so that
> we avoid using an if statement).
> It is possible to use the existing enum cq_type field "cq->is_tx",
> rename it (say to 'type'), and expand the enum cq_type with an
> additional value for TX_XDP.
> In addition, similarly to the previous suggestion, also here we
> would want to use two separate fields for the number of tx rings,
> one for netdev and one for xdp, and modify the rings iterators
> accordingly.
I think (2) makes sense, but the proof will be in the code, depending on
how easy to review it is.
> 
> [1]:
> https://patchwork.ozlabs.org/patch/649620/
> https://patchwork.ozlabs.org/patch/649619/
> 
> Another (not related) nit, as you're already working on the next V,
> I suggest we rename priv->prog to priv->bpf_prog.
I think xdp_prog is better, but point taken. Will update.
> 
> Regards,
> Tariq
