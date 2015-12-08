From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: Re: [PATCH 1/1] net:sctp: disable to inform ULP about transition
 from PF to active state
Date: Tue, 8 Dec 2015 10:11:31 -0200
Message-ID: <20151208121131.GA26906@mrl.redhat.com>
References: <1449568042-9176-1-git-send-email-zyjzyj2000@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
	linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
	alexandre.dietsch@windriver.com, stefan.costandache@windriver.com
To: zyjzyj2000@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:43643 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932535AbbLHMLh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Dec 2015 07:11:37 -0500
Content-Disposition: inline
In-Reply-To: <1449568042-9176-1-git-send-email-zyjzyj2000@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On Tue, Dec 08, 2015 at 05:47:22PM +0800, zyjzyj2000@gmail.com wrote:
> From: yzhu1 <zyjzyj2000@gmail.com>
> 
> This feature is introduced in the commit 5aa93bc "sctp: Implement
> quick failover draft from tsvwg". This feature should be disabled
> if the quick failover feature is disabled.
> 
> Signed-off-by: yzhu1 <zyjzyj2000@gmail.com>
> ---
>  net/sctp/associola.c |    3 ++-
>  1 file changed, 2 insertions(+), 1 deletion(-)
> 
> diff --git a/net/sctp/associola.c b/net/sctp/associola.c
> index 559afd0..7438625 100644
> --- a/net/sctp/associola.c
> +++ b/net/sctp/associola.c
> @@ -795,7 +795,8 @@ void sctp_assoc_control_transport(struct sctp_association *asoc,
>  		 * active state and set cwnd to 1 MTU, see SCTP
>  		 * Quick failover draft section 5.1, point 5
>  		 */
> -		if (transport->state == SCTP_PF) {
> +		if ((asoc->pf_retrans < asoc->max_retrans) && 
> +			(transport->state == SCTP_PF)) {
>  			ulp_notify = false;
>  			transport->cwnd = asoc->pathmtu;
>  		}

Didn't you confuse asoc->max_retrans with Path.Max.Retrans?
That draft refers to asoc->pf_retrans having to be bigger than
Path.Max.Retrans in order to disable PF, and asoc->max_retrans is
another thing, it's originated from net->sctp.max_retrans_association.

The check is performed later in the code:

+       if ((transport->state != SCTP_PF) &&
+          (asoc->pf_retrans < transport->pathmaxrxt) &&
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
+          (transport->error_count > asoc->pf_retrans)) {

This check should avoid that state transition as it will avoid the path
from entereing SCTP_PF state at all.

transport->pathmaxrst is originated from net->sctp.max_retrans_path.

Btw, you had indentantion issues with your patch. Extra () that aren't
needed and the second line should start at the column right after the
initial ( in the first line. Please run scripts/checkpatch.pl on it next
time. 

  Marcelo
