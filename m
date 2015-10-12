From: "santosh.shilimkar@oracle.com" <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next] RDS-TCP: Reset tcp callbacks if re-using an
 outgoing socket in rds_tcp_accept_one()
Date: Sun, 11 Oct 2015 19:32:22 -0700
Message-ID: <561B1BB6.2060208@oracle.com>
References: <20151011204944.GB14646@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151011204944.GB14646@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/11/15 1:49 PM, Sowmini Varadhan wrote:
>
> Consider the following "duelling syn" sequence between two peers A and B:
>          	A		B
>          	SYN1     -->
>          	    	<--	SYN2
>          	SYN2ACK  -->
>
> Note that the SYN/ACK has already been sent out by TCP before
> rds_tcp_accept_one() gets invoked as part of callbacks.
>
> If the inet_addr(A) is numerically less than inet_addr(B),
> the arbitration scheme in rds_tcp_accept_one() will prefer the
> TCP connection triggered by SYN1, and will send a CLOSE for the
> SYN2 (just after the SYN2ACK was sent).
>
> Since B also follows the same arbitration scheme, it will send the SYN-ACK
> for SYN1 that will set up a healthy ESTABLISHED connection on both sides.
> B will also get a  CLOSE for SYN2, which should result in the cleanup
> of the TCP state machine for SYN2, but it should not trigger any
> stale RDS-TCP callbacks (such as ->writespace, ->state_change etc),
> that would disrupt the progress of the SYN2 based RDS-TCP  connection.
>
> Thus the arbitration scheme in rds_tcp_accept_one() should restore
> rds_tcp callbacks for the winner before setting them up for the
> new accept socket, and also make sure that conn->c_outgoing
> is set to 0 so that we do not trigger any reconnect attempts on the
> passive side of the tcp socket in the future, in conformance with
> commit c82ac7e69efe ("net/rds: RDS-TCP: only initiate reconnect attempt
> on outgoing TCP socket.")
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---

Looks fine to me.

Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
