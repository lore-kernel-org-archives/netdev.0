From: Yuval Mintz <Yuval.Mintz@qlogic.com>
Subject: RE: [PATCH net-next v5 01/10] qed: Add module with basic common
 support
Date: Tue, 13 Oct 2015 04:08:31 +0000
Message-ID: <B5657A6538887040AD3A81F1008BEC63E467D6@avmb3.qlogic.org>
References: <1444674622-13059-1-git-send-email-Yuval.Mintz@qlogic.com>
 <1444674622-13059-2-git-send-email-Yuval.Mintz@qlogic.com>,<20151012230750.GA7378@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: netdev <netdev@vger.kernel.org>,
	Ariel Elior <Ariel.Elior@qlogic.com>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-0016ce01.pphosted.com ([67.231.148.157]:13546 "EHLO
	mx0a-0016ce01.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752537AbbJMEIj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Oct 2015 00:08:39 -0400
In-Reply-To: <20151012230750.GA7378@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 500 ko of a basic something is mildly reviewable for mere mortals.
Undertood, obviously. Thanks for the time you've put into this.

> [...]
> > +/* forward */
> > +struct qed_ptt_pool;
> > +struct qed_spq;
> > +struct qed_sb_info;
> > +struct qed_sb_attn_info;
> > +struct qed_cxt_mngr;
> > +struct qed_sb_sp_info;
> > +struct qed_mcp_info;
Could have been solved by adding additional header files.
But given the high number of files already introduced by this,
the thinking was that a couple of forward declerations was better than
adding lots of new header files to prevent this sort of dependency.

> [...]
> > +struct qed_simd_fp_handler {
> > +     void    *token;
> > +     void    (*func)(void *);
> > +};
> Use union * ?
The token is a cookie to be used by a func, so union isn't appropriate.

> [...]
> > +static int qed_ilt_shadow_alloc(struct qed_hwfn *p_hwfn)
> > +{
> > +     struct qed_cxt_mngr *p_mngr = p_hwfn->p_cxt_mngr;
> > +     struct qed_ilt_client_cfg *clients = p_mngr->clients;
> > +     struct qed_ilt_cli_blk *p_blk;
> > +     u32 size, i, j;
> > +     int rc;
> > +
> > +     size = qed_cxt_ilt_shadow_size(clients);
> > +     p_mngr->ilt_shadow = kcalloc(size, sizeof(struct qed_dma_mem),
> > +                                  GFP_KERNEL);
> > +     if (!p_mngr->ilt_shadow) {
> > +             DP_NOTICE(p_hwfn, "Failed to allocate ilt shadow table\n");
> > +             rc = -ENOMEM;
> > +             goto ilt_shadow_fail;
> > +     } else {
> > +             DP_VERBOSE(p_hwfn, QED_MSG_ILT,
> > +                        "Allocated 0x%x bytes for ilt shadow\n",
> > +                        (u32)(size * sizeof(struct qed_dma_mem)));
> > +     }
> The "else" branch after the "goto" isn't idiomatic.
Not that I mind, but is such a prefernce described in any style-guide?


> [...]
> > +static int qed_init_qm_info(struct qed_hwfn *p_hwfn)
> > +{
> [...]
> > +     /* PQs will be arranged as follows: First per-TC PQ then pure-LB quete.
> > +       */
> > +     qm_info->qm_pq_params = kzalloc(sizeof(*qm_info->qm_pq_params) *
> > +                                     num_pqs, GFP_ATOMIC);
> qed_init_qm_info is only used in qed_resc_alloc. qed_resc_alloc performs
> GFP_KERNEL alloc and qed_resc_alloc does not use qed_init_qm_info in
> a spinlocked section. I would thus expect both to use the same allocation
> flag.
I know we're wasteful in using GFP_ATOMIC in the driver in many places.
We've already revised this in our dev tree, but we're trying to use the
same code-base for the initial submission [otherwise it would make a
difficult task even more difficult].
Thanks for pointing this out, but unless this is considered crucial for inital
submission we'll fix it later on.

Thanks,
Yuval