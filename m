From: santosh shilimkar <santosh.shilimkar@oracle.com>
Subject: Re: [PATCH net-next 1/3] net/rds: Use a single TCP socket for both
 send and receive.
Date: Wed, 30 Sep 2015 09:04:49 -0700
Message-ID: <560C0821.9050300@oracle.com>
References: <cover.1443569239.git.sowmini.varadhan@oracle.com>
 <603874beb1dedd0a989d84740d22565bfc568c97.1443569239.git.sowmini.varadhan@oracle.com>
 <560C04AA.4050201@oracle.com> <20150930155806.GA8111@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, rds-devel@oss.oracle.com,
	ajaykumar.hotchandani@oracle.com, igor.maximov@oracle.com
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150930155806.GA8111@oracle.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/30/2015 8:58 AM, Sowmini Varadhan wrote:
> On (09/30/15 08:50), santosh shilimkar wrote:
>> minor nit though not a strict rule. Just to be consistent based on
>> what we are following.
>>
>> - core RDS patches "RDS:"
>> - RDS IB patches "RDS: IB:" or "RDS/IB:"
>> - RDS IW patches "RDS: IW:" or
>> - RDS TCP can use "RDS: TCP" or "RDS/TCP:"
>
> Ok, but in this case patch 1/3 the changes affect both core and rds-tcp
> modules.
>
As I said, these are not strict rules but just what have been followed.
I would use "RDS: TCP:" for first patch as well but I let you
take a call :-)

> Working on patchv2 that will address Sergei's comments and the
> kbuild-test-robot warning as well
>
OK. How about the dropped WARN_ON() question ?

>>
>> $subject
>> s/net/rds:/RDS:
>>
>> On 9/30/2015 6:45 AM, Sowmini Varadhan wrote:
>>> Commit f711a6ae062c ("net/rds: RDS-TCP: Always create a new rds_sock
>>> for an incoming connection.") modified rds-tcp so that an incoming SYN
>>> would ignore an existing "client" TCP connection which had the local
>>> port set to the transient port.  The motivation for ignoring the existing
>>> "client" connection in f711a6ae was to avoid race conditions and an
>>> endless duel of reconnect attempts triggered by a restart/abort of one
>>> of the nodes in the TCP connection.
>>>
>>> However, having separate sockets for active and passive sides
>>> is avoidable, and the simpler model of a single TCP socket for
>>> both send and receives of all RDS connections associated with
>>> that tcp socket makes for easier observability. We avoid the race
>>> conditions from f711a6ae by attempting reconnects in rds_conn_shutdown
>>> if, and only if, the (new) c_outgoing bit is set for RDS_TRANS_TCP.
>>> The c_outgoing bit is initialized in __rds_conn_create().
>>>
>>> A side-effect of re-using the client rds_connection for an incoming
>>> SYN is the potential of encountering duelling SYNs, i.e., we
>>> have an outgoing RDS_CONN_CONNECTING socket when we get the incoming
>>> SYN. The logic to arbitrate this criss-crossing SYN exchange in
>>> rds_tcp_accept_one() has been modified to emulate the BGP state
>>> machine: the smaller IP address should back off from the connection attempt.
>>>
>>> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
>>> ---
>>>   net/rds/connection.c |   22 ++++++----------------
>>>   net/rds/rds.h        |    4 +++-
>>>   net/rds/tcp_listen.c |   19 +++++++------------
>>>   3 files changed, 16 insertions(+), 29 deletions(-)
>>>
>>
>> [...]
>>
>>> diff --git a/net/rds/tcp_listen.c b/net/rds/tcp_listen.c
>>> index 444d78d..ee70d13 100644
>>> --- a/net/rds/tcp_listen.c
>>> +++ b/net/rds/tcp_listen.c
>>> @@ -110,28 +110,23 @@ int rds_tcp_accept_one(struct socket *sock)
>>>   		goto out;
>>>   	}
>>>   	/* An incoming SYN request came in, and TCP just accepted it.
>>> -	 * We always create a new conn for listen side of TCP, and do not
>>> -	 * add it to the c_hash_list.
>>>   	 *
>>>   	 * If the client reboots, this conn will need to be cleaned up.
>>>   	 * rds_tcp_state_change() will do that cleanup
>>>   	 */
>>>   	rs_tcp = (struct rds_tcp_connection *)conn->c_transport_data;
>>> -	WARN_ON(!rs_tcp || rs_tcp->t_sock);
>>> +	if (rs_tcp->t_sock && inet->inet_saddr < inet->inet_daddr) {
>>> +		struct sock *nsk = new_sock->sk;
>>>
>> Any reason you dropped the WARN_ON. Note that till we got commit
>> 74e98eb0 (" RDS: verify the underlying transport exists before creating
>> a connection") merged, we had an issue. That guards it now.
>>
>> Am curious about WARN_ON() and hence the question.
>>
>> Rest of the patch looks fine to me.
>> Acked-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
>>
