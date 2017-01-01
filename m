From: Xin Long <lucien.xin@gmail.com>
Subject: Re: [PATCH net-next 22/27] sctp: add rfc6525 section 5.2.4
Date: Sun, 1 Jan 2017 21:26:47 +0800
Message-ID: <CADvbK_dV2=uJfoPPMHj1nEYvGKvhszgmHOttN7CVgrPWxb2EeQ@mail.gmail.com>
References: <470b9f2b5248e0c1870c501f262a1887be66509b.1483269426.git.lucien.xin@gmail.com>
 <201701012026.kWKIK4Hy%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: kbuild-all@01.org, network dev <netdev@vger.kernel.org>,
        linux-sctp@vger.kernel.org,
        Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        davem <davem@davemloft.net>
To: kbuild test robot <lkp@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:35273 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755085AbdAAN0t (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 1 Jan 2017 08:26:49 -0500
In-Reply-To: <201701012026.kWKIK4Hy%fengguang.wu@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 1, 2017 at 8:14 PM, kbuild test robot <lkp@intel.com> wrote:
> Hi Xin,
>
> [auto build test WARNING on net-next/master]
>
> url:    https://github.com/0day-ci/linux/commits/Xin-Long/sctp-implement-rfc6525-sctp-stream-reconf/20170101-192844
> config: x86_64-randconfig-x015-201701 (attached as .config)
> compiler: gcc-6 (Debian 6.2.0-3) 6.2.0 20160901
> reproduce:
>         # save the attached .config to linux build tree
>         make ARCH=x86_64
>
> Note: it may well be a FALSE warning. FWIW you are at least aware of it now.
> http://gcc.gnu.org/wiki/Better_Uninitialized_Warnings
>
> All warnings (new ones prefixed by >>):
>
>    net/sctp/stream.c: In function 'sctp_process_strreset_outreq':
>    net/sctp/stream.c:140:9: warning: 'str_p' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      *evp = sctp_ulpevent_make_stream_reset_event(asoc,
>             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>       flags | SCTP_STREAM_RESET_OUTGOING_SSN, nums, str_p,
>       ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>       GFP_ATOMIC);
>       ~~~~~~~~~~~
>    net/sctp/stream.c: In function 'sctp_process_strreset_tsnreq':
>>> net/sctp/stream.c:283:9: warning: 'initial_tsn' may be used uninitialized in this function [-Wmaybe-uninitialized]
>      return sctp_make_strreset_tsnresp(asoc, result, request_seq,
>             ^~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>            asoc->next_tsn, initial_tsn);
>            ~~~~~~~~~~~~~~~~~~~~~~~~~~~~
As only when the result is not performed, initial_tsn variables is
uninitialized, peer side would ignore this value, so here is also
safe.

>
> vim +/initial_tsn +283 net/sctp/stream.c
>
>    134                  for (i = 0; i < asoc->streamincnt; i++)
>    135                          asoc->streamin[i].ssn = 0;
>    136          }
>    137
>    138          result = SCTP_STRRESET_PERFORMED;
>    139
>  > 140          *evp = sctp_ulpevent_make_stream_reset_event(asoc,
>    141                  flags | SCTP_STREAM_RESET_OUTGOING_SSN, nums, str_p,
>    142                  GFP_ATOMIC);
>    143
>    144  out:
>    145          return sctp_make_strreset_resp(asoc, result, request_seq);
>    146  }
>    147
>    148  struct sctp_chunk *sctp_process_strreset_inreq(
>    149                                  struct sctp_association *asoc,
>    150                                  union sctp_params param,
>    151                                  struct sctp_ulpevent **evp)
>    152  {
>    153          struct sctp_strreset_inreq *inreq = param.v;
>    154          __u32 result = SCTP_STRRESET_DENIED;
>    155          struct sctp_chunk *chunk = NULL;
>    156          __u16 i, nums, *str_p;
>    157          __u32 request_seq;
>    158
>    159          request_seq = ntohl(inreq->request_seq);
>    160          if (request_seq > asoc->strreset_inseq) {
>    161                  result = SCTP_STRRESET_ERR_BAD_SEQNO;
>    162                  goto out;
>    163          } else if (request_seq == asoc->strreset_inseq) {
>    164                  asoc->strreset_inseq++;
>    165          }
>    166
>    167          if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_STREAM_REQ))
>    168                  goto out;
>    169
>    170          if (asoc->strreset_outstanding) {
>    171                  result = SCTP_STRRESET_ERR_IN_PROGRESS;
>    172                  goto out;
>    173          }
>    174
>    175          nums = (ntohs(param.p->length) - sizeof(*inreq)) / 2;
>    176          str_p = inreq->list_of_streams;
>    177          for (i = 0; i < nums; i++) {
>    178                  str_p[i] = ntohs(str_p[i]);
>    179                  if (str_p[i] >= asoc->streamoutcnt) {
>    180                          result = SCTP_STRRESET_ERR_WRONG_SSN;
>    181                          goto out;
>    182                  }
>    183          }
>    184
>    185          chunk = sctp_make_strreset_req(asoc, nums, str_p, 1, 0);
>    186          if (!chunk)
>    187                  goto out;
>    188
>    189          if (nums)
>    190                  for (i = 0; i < nums; i++)
>    191                          asoc->streamout[str_p[i]].state =
>    192                                                     SCTP_STREAM_CLOSED;
>    193          else
>    194                  for (i = 0; i < asoc->streamoutcnt; i++)
>    195                          asoc->streamout[i].state = SCTP_STREAM_CLOSED;
>    196
>    197          asoc->strreset_chunk = chunk;
>    198          asoc->strreset_outstanding = 1;
>    199          sctp_chunk_hold(asoc->strreset_chunk);
>    200
>    201          *evp = sctp_ulpevent_make_stream_reset_event(asoc,
>    202                  SCTP_STREAM_RESET_INCOMING_SSN, nums, str_p, GFP_ATOMIC);
>    203
>    204  out:
>    205          if (!chunk)
>    206                  chunk =  sctp_make_strreset_resp(asoc, result, request_seq);
>    207
>    208          return chunk;
>    209  }
>    210
>    211  struct sctp_chunk *sctp_process_strreset_tsnreq(
>    212                                  struct sctp_association *asoc,
>    213                                  union sctp_params param,
>    214                                  struct sctp_ulpevent **evp)
>    215  {
>    216          struct sctp_strreset_tsnreq *tsnreq = param.v;
>    217          __u32 request_seq, initial_tsn, max_tsn_seen;
>    218          __u32 result = SCTP_STRRESET_DENIED;
>    219          __u16 i;
>    220
>    221          request_seq = ntohl(tsnreq->request_seq);
>    222          if (request_seq > asoc->strreset_inseq) {
>    223                  result = SCTP_STRRESET_ERR_BAD_SEQNO;
>    224                  goto out;
>    225          } else if (request_seq == asoc->strreset_inseq) {
>    226                  asoc->strreset_inseq++;
>    227          }
>    228
>    229          if (!(asoc->strreset_enable & SCTP_ENABLE_RESET_ASSOC_REQ))
>    230                  goto out;
>    231
>    232          if (asoc->strreset_outstanding) {
>    233                  result = SCTP_STRRESET_ERR_IN_PROGRESS;
>    234                  goto out;
>    235          }
>    236
>    237          /* G3: The same processing as though a SACK chunk with no gap report
>    238           *     and a cumulative TSN ACK of the Sender's Next TSN minus 1 were
>    239           *     received MUST be performed.
>    240           */
>    241          max_tsn_seen = sctp_tsnmap_get_max_tsn_seen(&asoc->peer.tsn_map);
>    242          sctp_ulpq_reasm_flushtsn(&asoc->ulpq, max_tsn_seen);
>    243          sctp_ulpq_abort_pd(&asoc->ulpq, GFP_ATOMIC);
>    244
>    245          /* G1: Compute an appropriate value for the Receiver's Next TSN -- the
>    246           *     TSN that the peer should use to send the next DATA chunk.  The
>    247           *     value SHOULD be the smallest TSN not acknowledged by the
>    248           *     receiver of the request plus 2^31.
>    249           */
>    250          initial_tsn = sctp_tsnmap_get_ctsn(&asoc->peer.tsn_map) + (1 << 31);
>    251          sctp_tsnmap_init(&asoc->peer.tsn_map, SCTP_TSN_MAP_INITIAL,
>    252                           initial_tsn, GFP_ATOMIC);
>    253
>    254          /* G4: The same processing as though a FWD-TSN chunk (as defined in
>    255           *     [RFC3758]) with all streams affected and a new cumulative TSN
>    256           *     ACK of the Receiver's Next TSN minus 1 were received MUST be
>    257           *     performed.
>    258           */
>    259          sctp_outq_free(&asoc->outqueue);
>    260
>    261          /* G2: Compute an appropriate value for the local endpoint's next TSN,
>    262           *     i.e., the next TSN assigned by the receiver of the SSN/TSN reset
>    263           *     chunk.  The value SHOULD be the highest TSN sent by the receiver
>    264           *     of the request plus 1.
>    265           */
>    266          asoc->ctsn_ack_point = asoc->next_tsn - 1;
>    267          asoc->adv_peer_ack_point = asoc->ctsn_ack_point;
>    268
>    269          /* G5:  The next expected and outgoing SSNs MUST be reset to 0 for all
>    270           *      incoming and outgoing streams.
>    271           */
>    272          for (i = 0; i < asoc->streamoutcnt; i++)
>    273                  asoc->streamout[i].ssn = 0;
>    274          for (i = 0; i < asoc->streamincnt; i++)
>    275                  asoc->streamin[i].ssn = 0;
>    276
>    277          result = SCTP_STRRESET_PERFORMED;
>    278
>    279          *evp = sctp_ulpevent_make_assoc_reset_event(asoc,
>    280                  0, initial_tsn, asoc->next_tsn, GFP_ATOMIC);
>    281
>    282  out:
>  > 283          return sctp_make_strreset_tsnresp(asoc, result, request_seq,
>    284                                            asoc->next_tsn, initial_tsn);
>    285  }
>
> ---
> 0-DAY kernel test infrastructure                Open Source Technology Center
> https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
