From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCHv2 net-next 1/6] sctp: add sctp_info dump api for sctp_diag
Date: Sun, 10 Apr 2016 00:10:41 +0800
Message-ID: <CADvbK_dzvjT=pFYP8uRDa8naNWUp+dkUHSVXP+Y8P0U3=nQM8g@mail.gmail.com>
References: <cover.1460177331.git.lucien.xin@gmail.com>
	<c507274a984bd1b0a7e7a59d1e825352536efd25.1460177331.git.lucien.xin@gmail.com>
	<1460179179.6473.476.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>, linux-sctp@vger.kernel.org,
	Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
	Vlad Yasevich <vyasevich@gmail.com>, daniel@iogearbox.net,
	davem <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:34413 "EHLO
	mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753853AbcDIQKm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 12:10:42 -0400
In-Reply-To: <1460179179.6473.476.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Apr 9, 2016 at 1:19 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Sat, 2016-04-09 at 12:53 +0800, Xin Long wrote:
>> sctp_diag will dump some important details of sctp's assoc or ep, we use
>> sctp_info to describe them,  sctp_get_sctp_info to get them, and export
>> it to sctp_diag.ko.
>>
>
>
>> +int sctp_get_sctp_info(struct sock *sk, struct sctp_association *asoc,
>> +                    struct sctp_info *info)
>> +{
>> +     struct sctp_transport *prim;
>> +     struct list_head *pos, *temp;
>> +     int mask;
>> +
>> +     memset(info, 0, sizeof(*info));
>> +     if (!asoc) {
>> +             struct sctp_sock *sp = sctp_sk(sk);
>> +
>> +             info->sctpi_s_autoclose = sp->autoclose;
>> +             info->sctpi_s_adaptation_ind = sp->adaptation_ind;
>> +             info->sctpi_s_pd_point = sp->pd_point;
>> +             info->sctpi_s_nodelay = sp->nodelay;
>> +             info->sctpi_s_disable_fragments = sp->disable_fragments;
>> +             info->sctpi_s_v4mapped = sp->v4mapped;
>> +             info->sctpi_s_frag_interleave = sp->frag_interleave;
>> +
>> +             return 0;
>> +     }
>> +
>> +     info->sctpi_tag = asoc->c.my_vtag;
>> +     info->sctpi_state = asoc->state;
>> +     info->sctpi_rwnd = asoc->a_rwnd;
>> +     info->sctpi_unackdata = asoc->unack_data;
>> +     info->sctpi_penddata = sctp_tsnmap_pending(&asoc->peer.tsn_map);
>> +     info->sctpi_instrms = asoc->c.sinit_max_instreams;
>> +     info->sctpi_outstrms = asoc->c.sinit_num_ostreams;
>> +     list_for_each_safe(pos, temp, &asoc->base.inqueue.in_chunk_list)
>> +             info->sctpi_inqueue++;
>> +     list_for_each_safe(pos, temp, &asoc->outqueue.out_chunk_list)
>> +             info->sctpi_outqueue++;
>
> Is this safe ?
>
> Do you own the lock on socket or whatever lock protecting this list ?
>
there are 2 places will call these codes,
1. sctp_diag_dump -> sctp_for_each_transport -> sctp_tsp_dump
this one will use lock_sock to protect them. I think this one is ok.

1. sctp_diag_dump_one -> sctp_transport_lookup_process-> sctp_tsp_dump_one
this one just holds the tsp. and we're using  list_for_each_safe here now,
isn't it enough ?


>
>> +     info->sctpi_overall_error = asoc->overall_error_count;
>> +     info->sctpi_max_burst = asoc->max_burst;
>> +     info->sctpi_maxseg = asoc->frag_point;
>> +     info->sctpi_peer_rwnd = asoc->peer.rwnd;
>> +     info->sctpi_peer_tag = asoc->c.peer_vtag;
>> +
>> +     mask = asoc->peer.ecn_capable << 1;
>> +     mask = (mask | asoc->peer.ipv4_address) << 1;
>> +     mask = (mask | asoc->peer.ipv6_address) << 1;
>> +     mask = (mask | asoc->peer.hostname_address) << 1;
>> +     mask = (mask | asoc->peer.asconf_capable) << 1;
>> +     mask = (mask | asoc->peer.prsctp_capable) << 1;
>> +     mask = (mask | asoc->peer.auth_capable);
>> +     info->sctpi_peer_capable = mask;
>> +     mask = asoc->peer.sack_needed << 1;
>> +     mask = (mask | asoc->peer.sack_generation) << 1;
>> +     mask = (mask | asoc->peer.zero_window_announced);
>> +     info->sctpi_peer_sack = mask;
>> +
>> +     info->sctpi_isacks = asoc->stats.isacks;
>> +     info->sctpi_osacks = asoc->stats.osacks;
>> +     info->sctpi_opackets = asoc->stats.opackets;
>> +     info->sctpi_ipackets = asoc->stats.ipackets;
>> +     info->sctpi_rtxchunks = asoc->stats.rtxchunks;
>> +     info->sctpi_outofseqtsns = asoc->stats.outofseqtsns;
>> +     info->sctpi_idupchunks = asoc->stats.idupchunks;
>> +     info->sctpi_gapcnt = asoc->stats.gapcnt;
>> +     info->sctpi_ouodchunks = asoc->stats.ouodchunks;
>> +     info->sctpi_iuodchunks = asoc->stats.iuodchunks;
>> +     info->sctpi_oodchunks = asoc->stats.oodchunks;
>> +     info->sctpi_iodchunks = asoc->stats.iodchunks;
>> +     info->sctpi_octrlchunks = asoc->stats.octrlchunks;
>> +     info->sctpi_ictrlchunks = asoc->stats.ictrlchunks;
>> +
>> +     prim = asoc->peer.primary_path;
>> +     memcpy(&info->sctpi_p_address, &prim->ipaddr,
>> +            sizeof(struct sockaddr_storage));
>> +     info->sctpi_p_state = prim->state;
>> +     info->sctpi_p_cwnd = prim->cwnd;
>> +     info->sctpi_p_srtt = prim->srtt;
>> +     info->sctpi_p_rto = jiffies_to_msecs(prim->rto);
>> +     info->sctpi_p_hbinterval = prim->hbinterval;
>> +     info->sctpi_p_pathmaxrxt = prim->pathmaxrxt;
>> +     info->sctpi_p_sackdelay = jiffies_to_msecs(prim->sackdelay);
>> +     info->sctpi_p_ssthresh = prim->ssthresh;
>> +     info->sctpi_p_partial_bytes_acked = prim->partial_bytes_acked;
>> +     info->sctpi_p_flight_size = prim->flight_size;
>> +     info->sctpi_p_error = prim->error_count;
>> +
>> +     return 0;
>> +}
>> +EXPORT_SYMBOL_GPL(sctp_get_sctp_info);
>
> info is not guaranteed to be aligned on 8 bytes.
>
> You need to use put_unaligned()
>
> Check commit ff5d749772018 ("tcp: beware of alignments in
> tcp_get_info()") for details.
Ok,  I will.

>
>
>
