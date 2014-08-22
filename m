From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH net 2/2] net: sctp: fix suboptimal edge-case on
 non-active active/retrans path selection
Date: Fri, 22 Aug 2014 08:30:05 -0400
Message-ID: <20140822123005.GC9307@hmsreliant.think-freely.org>
References: <1408705410-28558-1-git-send-email-dborkman@redhat.com>
 <1408705410-28558-3-git-send-email-dborkman@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	linux-sctp@vger.kernel.org
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49180 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755919AbaHVMaP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 08:30:15 -0400
Content-Disposition: inline
In-Reply-To: <1408705410-28558-3-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 22, 2014 at 01:03:30PM +0200, Daniel Borkmann wrote:
> In SCTP, selection of active (T.ACT) and retransmission (T.RET)
> transports is being done whenever transport control operations
> (UP, DOWN, PF, ...) are engaged through sctp_assoc_control_transport().
> 
> Commits 4c47af4d5eb2 ("net: sctp: rework multihoming retransmission
> path selection to rfc4960") and a7288c4dd509 ("net: sctp: improve
> sctp_select_active_and_retran_path selection") have both improved
> it towards a more fine-grained and optimal path selection.
> 
> Currently, the selection algorithm for T.ACT and T.RET is as follows:
> 
> 1) Elect the two most recently used ACTIVE transports T1, T2 for
>    T.ACT, T.RET, where T.ACT<-T1 and T1 is most recently used
> 2) In case primary path T.PRI not in {T1, T2} but ACTIVE, set
>    T.ACT<-T.PRI and T.RET<-T1
> 3) If only T1 is ACTIVE from the set, set T.ACT<-T1 and T.RET<-T1
> 4) If none is ACTIVE, set T.ACT<-best(T.PRI, T.RET, T3) where
>    T3 is the most recently used (if avail) in PF, set T.RET<-T.PRI
> 
> Prior to above commits, 4) was simply a camp on T.ACT<-T.PRI and
> T.RET<-T.PRI, ignoring possible paths in PF. Camping on T.PRI is
> still slightly suboptimal as it can lead to the following scenario:
> 
> Setup:
>         <A>                                <B>
>     T1: p1p1 (10.0.10.10) <==>  .'`)  <==> p1p1 (10.0.10.12)  <= T.PRI
>     T2: p1p2 (10.0.10.20) <==> (_ . ) <==> p1p2 (10.0.10.22)
> 
>     net.sctp.rto_min = 1000
>     net.sctp.path_max_retrans = 2
>     net.sctp.pf_retrans = 0
>     net.sctp.hb_interval = 1000
> 
> T.PRI is permanently down, T2 is put briefly into PF state (e.g. due to
> link flapping). Here, the first time transmission is sent over PF path
> T2 as it's the only non-INACTIVE path, but the retransmitted data-chunks
> are sent over the INACTIVE path T1 (T.PRI), which is not good.
> 
> After the patch, it's choosing better transports in both cases by
> modifying step 4):
> 
> 4) If none is ACTIVE, set T.ACT_new<-best(T.ACT_old, T3) where T3 is
>    the most recently used (if avail) in PF, set T.RET<-T.ACT_new
> 
> This will still select a best possible path in PF if available (which
> can also include T.PRI/T.RET), and set both T.ACT/T.RET to it.
> 
> In case sctp_assoc_control_transport() *just* put T.ACT_old into INACTIVE
> as it transitioned from ACTIVE->PF->INACTIVE and stays in INACTIVE just
> for a very short while before going back ACTIVE, it will guarantee that
> this path will be reselected for T.ACT/T.RET since T3 (PF) is not
> available.
> 
> Previously, this was not possible, as we would only select between T.PRI
> and T.RET, and a possible T3 would be NULL due to the fact that we have
> just transitioned T3 in sctp_assoc_control_transport() from PF->INACTIVE
> and would select a suboptimal path when T.PRI/T.RET have worse properties.
> 
> In the case that T.ACT_old permanently went to INACTIVE during this
> transition and there's no PF path available, plus T.PRI and T.RET are
> INACTIVE as well, we would now camp on T.ACT_old, but if everything is
> being INACTIVE there's really not much we can do except hoping for a
> successful HB to bring one of the transports back up again and, thus
> cause a new selection through sctp_assoc_control_transport().
> 
> Now both tests work fine:
> 
> Case 1:
> 
>  1. T1 S(ACTIVE) T.ACT
>     T2 S(ACTIVE) T.RET
> 
>  2. T1 S(ACTIVE) T.ACT, T.RET
>     T2 S(PF)
> 
>  3. T1 S(ACTIVE) T.ACT, T.RET
>     T2 S(INACTIVE)
> 
>  5. T1 S(PF) T.ACT, T.RET
>     T2 S(INACTIVE)
> 
> [ 5.1 T1 S(INACTIVE) T.ACT, T.RET
>       T2 S(INACTIVE) ]
> 
>  6. T1 S(ACTIVE) T.ACT, T.RET
>     T2 S(INACTIVE)
> 
>  7. T1 S(ACTIVE) T.ACT
>     T2 S(ACTIVE) T.RET
> 
> Case 2:
> 
>  1. T1 S(ACTIVE) T.ACT
>     T2 S(ACTIVE) T.RET
> 
>  2. T1 S(PF)
>     T2 S(ACTIVE) T.ACT, T.RET
> 
>  3. T1 S(INACTIVE)
>     T2 S(ACTIVE) T.ACT, T.RET
> 
>  5. T1 S(INACTIVE)
>     T2 S(PF) T.ACT, T.RET
> 
> [ 5.1 T1 S(INACTIVE)
>       T2 S(INACTIVE) T.ACT, T.RET ]
> 
>  6. T1 S(INACTIVE)
>     T2 S(ACTIVE) T.ACT, T.RET
> 
>  7. T1 S(ACTIVE) T.ACT
>     T2 S(ACTIVE) T.RET
> 
> Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
> ---
>  net/sctp/associola.c | 9 +++------
>  1 file changed, 3 insertions(+), 6 deletions(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 104fae4..a88b852 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -1356,14 +1356,11 @@ static void sctp_select_active_and_retran_path(struct sctp_association *asoc)
>  		trans_sec = trans_pri;
>  
>  	/* If we failed to find a usable transport, just camp on the
> -	 * primary or retran, even if they are inactive, if possible
> -	 * pick a PF iff it's the better choice.
> +	 * active or pick a PF iff it's the better choice.
>  	 */
>  	if (trans_pri == NULL) {
> -		trans_pri = sctp_trans_elect_best(asoc->peer.primary_path,
> -						  asoc->peer.retran_path);
> -		trans_pri = sctp_trans_elect_best(trans_pri, trans_pf);
> -		trans_sec = asoc->peer.primary_path;
> +		trans_pri = sctp_trans_elect_best(asoc->peer.active_path, trans_pf);
> +		trans_sec = trans_pri;
>  	}
>  
>  	/* Set the active and retran transports. */
> -- 
> 1.7.11.7
> 
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sctp" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
Acked-by: Neil Horman <nhorman@tuxdriver.com>
