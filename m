From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH v8 net-next 6/7] ixgbe: add support for
	ndo_ll_poll
Date: Wed, 5 Jun 2013 08:50:42 +0000 (UTC)
Message-ID: <komu51$jv$1@ger.gmane.org>
References: <20130603080107.18273.34279.stgit@ladj378.jer.intel.com>
	<20130603080209.18273.16368.stgit@ladj378.jer.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: e1000-devel@lists.sourceforge.net
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

On Mon, 03 Jun 2013 at 08:02 GMT, Eliezer Tamir <eliezer.tamir@linux.intel.com> wrote:
> +/* called from the device poll rutine to get ownership of a q_vector */
> +static inline bool ixgbe_qv_lock_napi(struct ixgbe_q_vector *q_vector)
> +{
> +	int rc = true;

        bool rc = true;

> +	spin_lock(&q_vector->lock);
> +	if (q_vector->state & IXGBE_QV_LOCKED) {
> +		WARN_ON(q_vector->state & IXGBE_QV_STATE_NAPI);
> +		q_vector->state |= IXGBE_QV_STATE_NAPI_YIELD;
> +		rc = false;
> +	} else
> +		/* we don't care if someone yielded */
> +		q_vector->state = IXGBE_QV_STATE_NAPI;
> +	spin_unlock(&q_vector->lock);
> +	return rc;
> +}
> +
> +/* returns true is someone tried to get the qv while napi had it */
> +static inline bool ixgbe_qv_unlock_napi(struct ixgbe_q_vector *q_vector)
> +{
> +	int rc = false;

        bool rc = false;


> +	spin_lock(&q_vector->lock);
> +	WARN_ON(q_vector->state & (IXGBE_QV_STATE_POLL |
> +			       IXGBE_QV_STATE_NAPI_YIELD));
> +
> +	if (q_vector->state & IXGBE_QV_STATE_POLL_YIELD)
> +		rc = true;
> +	q_vector->state = IXGBE_QV_STATE_IDLE;
> +	spin_unlock(&q_vector->lock);
> +	return rc;
> +}
> +
> +/* called from ixgbe_low_latency_poll() */
> +static inline bool ixgbe_qv_lock_poll(struct ixgbe_q_vector *q_vector)
> +{
> +	int rc = true;

Ditto.

> +	spin_lock_bh(&q_vector->lock);
> +	if ((q_vector->state & IXGBE_QV_LOCKED)) {
> +		q_vector->state |= IXGBE_QV_STATE_POLL_YIELD;
> +		rc = false;
> +	} else
> +		/* preserve yield marks */
> +		q_vector->state |= IXGBE_QV_STATE_POLL;
> +	spin_unlock_bh(&q_vector->lock);
> +	return rc;
> +}
> +
> +/* returns true if someone tried to get the qv while it was locked */
> +static inline bool ixgbe_qv_unlock_poll(struct ixgbe_q_vector *q_vector)
> +{
> +	int rc = false;

Ditto.

> +	spin_lock_bh(&q_vector->lock);
> +	WARN_ON(q_vector->state & (IXGBE_QV_STATE_NAPI));
> +
> +	if (q_vector->state & IXGBE_QV_STATE_POLL_YIELD)
> +		rc = true;
> +	q_vector->state = IXGBE_QV_STATE_IDLE;
> +	spin_unlock_bh(&q_vector->lock);
> +	return rc;
> +}
> +


------------------------------------------------------------------------------
How ServiceNow helps IT people transform IT departments:
1. A cloud service to automate IT design, transition and operations
2. Dashboards that offer high-level views of enterprise services
3. A single system of record for all IT processes
http://p.sf.net/sfu/servicenow-d2d-j
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
