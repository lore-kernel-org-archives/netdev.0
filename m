From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv2 net-next 1/6] sctp: add sctp_info dump api for
 sctp_diag
Date: Sat, 09 Apr 2016 10:29:07 -0700
Message-ID: <1460222947.6473.497.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
	 <c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
	 <1460179179.6473.476.camel@edumazet-glaptop3.roam.corp.google.com>
	 <CADvbK_dzvjT=pFYP8uRDa8naNWUp+dkUHSVXP+Y8P0U3=nQM8g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f174.google.com ([209.85.220.174]:36511 "EHLO
	mail-qk0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753884AbcDIR3L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 13:29:11 -0400
In-Reply-To: <CADvbK_dzvjT=pFYP8uRDa8naNWUp+dkUHSVXP+Y8P0U3=nQM8g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2016-04-10 at 00:10 +0800, Xin Long wrote:
> On Sat, Apr 9, 2016 at 1:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > On Sat, 2016-04-09 at 12:53 +0800, Xin Long wrote:
> >> sctp_diag will dump some important details of sctp's assoc or ep, we use
> >> sctp_info to describe them,  sctp_get_sctp_info to get them, and export
> >> it to sctp_diag.ko.
> >>
> >
> >
> >> +int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
> >> +                    struct sctp_info *info)
> >> +{
> >> +     struct sctp_transport *prim;
> >> +     struct list_head *pos, *temp;
> >> +     int mask;
> >> +
> >> +     memset(info, 0, sizeof(*info));
> >> +     if (!asoc) {
> >> +             struct sctp_sock *sp = sctp_sk(sk);
> >> +
> >> +             info->sctpi_s_autoclose = sp->autoclose;
> >> +             info->sctpi_s_adaptation_ind = sp->adaptation_ind;
> >> +             info->sctpi_s_pd_point = sp->pd_point;
> >> +             info->sctpi_s_nodelay = sp->nodelay;
> >> +             info->sctpi_s_disable_fragments = sp->disable_fragments;
> >> +             info->sctpi_s_v4mapped = sp->v4mapped;
> >> +             info->sctpi_s_frag_interleave = sp->frag_interleave;
> >> +
> >> +             return 0;
> >> +     }
> >> +
> >> +     info->sctpi_tag = asoc->c.my_vtag;
> >> +     info->sctpi_state = asoc->state;
> >> +     info->sctpi_rwnd = asoc->a_rwnd;
> >> +     info->sctpi_unackdata = asoc->unack_data;
> >> +     info->sctpi_penddata = sctp_tsnmap_pending(&asoc->peer.tsn_map);
> >> +     info->sctpi_instrms = asoc->c.sinit_max_instreams;
> >> +     info->sctpi_outstrms = asoc->c.sinit_num_ostreams;
> >> +     list_for_each_safe(pos, temp, &asoc->base.inqueue.in_chunk_list)
> >> +             info->sctpi_inqueue++;
> >> +     list_for_each_safe(pos, temp, &asoc->outqueue.out_chunk_list)
> >> +             info->sctpi_outqueue++;
> >
> > Is this safe ?
> >
> > Do you own the lock on socket or whatever lock protecting this list ?
> >
> there are 2 places will call these codes,
> 1. sctp_diag_dump -> sctp_for_each_transport -> sctp_tsp_dump
> this one will use lock_sock to protect them. I think this one is ok.
> 
> 1. sctp_diag_dump_one -> sctp_transport_lookup_process-> sctp_tsp_dump_one
> this one just holds the tsp. and we're using  list_for_each_safe here now,
> isn't it enough ?
> 

You tell me ;)

For sure in tcp_get_info() the socket is sometimes locked, and sometimes
is not locked, depending on the caller.

So we had to use only lockless accesses.
