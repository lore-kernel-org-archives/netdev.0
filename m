From: Aidas Kasparas <a.kasparas@gmc.lt>
Subject: Re: IPSEC: on behavior of acquire
Date: Sun, 03 Apr 2005 11:28:54 +0300
Message-ID: <424FA946.70809@gmc.lt>
References: <1112405303.1096.37.camel@jzny.localdomain>
 <424E454D.4090402@gmc.lt> <1112477326.1088.321.camel@jzny.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7BIT
Cc: ipsec-tools-devel@lists.sourceforge.net, netdev <netdev@oss.sgi.com>,
        nakam@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
In-reply-to: <1112477326.1088.321.camel@jzny.localdomain>
To: hadi@cyberus.ca
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



jamal wrote:
> On Sat, 2005-04-02 at 02:10, Aidas Kasparas wrote:
> 
> 
>>Re 1 try only. There is little sense to do more tries. If there is no 
>>deamon listening to pfkey messages, then no connection will be made no 
>>matter how many retries you'll do. If deamon/link/peer is slow and SA 
>>was not established before timeout expired, then repeated acquire will 
>>be simply ignored (deamon will find out that negotiation is already in 
>>progress, there is no reason to start another negotiation and therefore 
>>will drop that acquire request). And the only situation where repeated 
>>acquires may help is when pfkey messages are lost. 
> 
> 
> Exactly what i was trying to emulate - lost messages. 

Your emulation was not correct. More correct would have been to start KE 
daemon, let it fully initialize (open pfkey socket, inform kernel that 
it is interested in acquire messages), then stop it (via debugger or 
kill -STOP) and only then send pings or other traffic and see what will 
happen. This is because there are different paths in xfrm+pfkey for 
cases 1) when there is no KE daemon and 2) when daemon is, but for some 
reason it does not establish a SA and therefore reaction to traffic is 
different.

In the first case it's xfrm_lookup() ->xfrm_tmpl_resolve() 
->xfrm_state_find() ->xfrm_state.c:km_query() ->pfkey_send_acquire() 
->pfkey_broadcast() ->return -ESRCH. This error code goes unchanged back 
to xfrm_state_find, where it is remaped into itself (other possible 
values are -EAGAIN and -ENOMEM). And then this error code goes back to 
application.

In the second case it's xfrm_lookup() ->xfrm_tmpl_resolve() 
->xfrm_state_find() ->xfrm_state.c:km_query() ->pfkey_send_acquire() 
->pfkey_broadcast() ->pfkey_broadcast_one() -> return 0 also sent 
unchanged back to function xfrm_state_find, where SA is put into state 
XFRM_STATE_ACQ. xfrm_tmpl_resolve() returns -EAGAIN. xfrm_lookup then 
organizes timeout, and if the state was not changed after that timeout, 
returns -EAGAIN to the application.

On the other hand, analysis above shows that return code is choosen by 
xfrm framework, therefore if error code has to be changed, it should be 
changed in xfrm, not in pfkey or netlink code.

> I would expect it
> to be the rule to loose messages - but given theres no guarantee of
> delivery, messages could be lost.
> 
> 
>>But pfkey was not 
>>designed to survive message loses, therefore you should not operate your 
>>boxes in mode when lost pfkey messages are a rule, not an exception. And 
>>on the other hand, occasional pfkey message loses can be worked around 
>>by applications/user retry.
>>
> 
> 
> I think its more than just pfkey (or netlink) - rather the ipsec
> framework itself.
> 
> One could look at the acquire as part of the "connection" setup
> (for lack of better description). Without the acquire succeeding, theres
> no connection..(assuming that to be a policy).
> Therefore if acquire is not supposed to be delivered with some certainty
> (read: retries) then theres some resiliciency issues IMO.

OK, To avoid speaking about apples and oranges let's first find out 
where you see the problem. In the ipsec framework there are the 
following players (I'm speaking about pfkey case; netlink may be little 
different):

xfrm <-> pfkey <-> KE daemon <-> remote peer

xfrm-pfkey communication is based on function calls. For them to fail 
something really weird has to happen with your kernel.

KE deamon - remote peer communications are done on UDP/500, UDP/4500 
according to internet standards. Packet retransmissions are implemented 
the way standards require, therefore it is not a fatal condition if some 
packet will be lost on the way. And there is no 1:1 correspondence 
between packets sent over internet and those sent over pfkey socket. 
These communications are performed relatively independent. There is no 
need to receive extra acquire pfkey message to retransmit packet which 
initiates SA setup with remote peer.

pfkey - KE daemon communication is performed over message socket. All 
the communication is performed within single box. More, only the kernel 
and userspace process are involved. Therefore I see only the following 
cases when message can be not delivered:
1) message is too big to fit into socket's buffer;
2) kernel decides to drop that socket buffer and reuse memory for 
something else;
3) KE daemon do not get [enough] CPU time to handle messages;
4) bug in KE daemon prevents it from reading messages.
if you know other case, please, let me know.

(1) do happens when there is big SPD/SAD and setkey/racoon request to 
dump it all. It is known pfkey architectural limitation. Acquire 
messages are small, therefore this can happen only when such call is 
made right after responce to big DUMP was generated. In racoon case SPD 
dump is performed only on daemon startup (and even then it is possible 
that it is not strictly necessary). Extra acquire message may make sense 
only if it is sent after some timeout. But again, KE daemon start is 
more exception than rule and applications can be started only after some 
delay after KE daemon has started.

I'm not sure how realistic is (2). But it and (3) are clear resource 
shortage cases. Under no circumstances they should be allowed. And in 
(3) case extra acquire message definitely won't help situation.

Inn (4) case it is KE daemon who is guilty, not pfkey. Extra message 
will not cure this case too.

>  
> Note: Sometimes theres no app. Example a packet coming into a gateway.
> 

What do you have in mind?

If it is ISAKMP negotiation from remote peer, then it comes over UDP/500 
or UDP/4500 over IP socket and not via acquire message via pfkey socket.

If it is ESP/AH packet with unknown SPI, then kernel simply drops it and 
do not send any acquire messages.

If it is something else, please explain.

>> pfkey code found that there is nothing receiving 
>>acquire messages => there is no chance that any process will setup 
>>required SAs and tried to inform about that (I agree, return code is not 
>>very informative, at least until you learn about reasons why it is 
>>such). If you would have racoon (or other pfkey based ISAKMP daemon) 
>>running, you would get "resource temporarily unavailable" (don't know 
>>which error code corresponds to that message), which IMHO is ok (if it 
>>is not, please explain).
>>
> 
> 
> Havent tried that - the reason i said restart was the right signal was
> mainly that an app could translate that to mean "try again".
> In other words even in the case of ping -c1 the ping app could have 
> reattempted.

If there is security policy which is not satisfied and there is nobody 
which could make it satisfied, then why should we give application false 
hope that on retry things will change?

> 
> On Sat, 2005-04-02 at 07:25, Zilvinas Valinskas wrote:
> 
>>EBUSY I think it is.
>>
>>I am not entirely sure it is ok to return such error, some applications are
>>not coping nicely with it. Perhaps ECONNREFUSED is more reasonable - as it 
>>doesn't brake old apps assumption (connection cannot be established,
>>doesn't matter if that is due to routing or IPsec SPD or anything else).
>>
> 
> 
> What about ERESTART the way netlink does it right now?

I suspect that ERESTART is generated not by netlink, but by 
xfrm_lookup() function when signal_pending(current) is true. Why that 
function returns true in netlink case but not in pfkey case I don't 
know. IMHO, xfrm_lookup() returns correct error codes in that case.

> ECONNREFUSED is probably not a bad idea.
> ping was clearly dumb and didnt do anything with the info.
> Overall, I think the errors are unfortunately not descriptive at all.

I don't like ECONNREFUSED in this place. As a user if I would receive 
ECONNREFUSED message then I would address application server admin or 
remote host admin to resolve the problem. But the problem is in network 
setup and therefore person responsible for networks should be contacted. 
Therefore, I would like more ENETUNREACH or EHOSTUNREACH.

P.S. for analysis kernel source from debian distribution was used (v.2.6.9)

-- 
Aidas Kasparas
IT administrator
GM Consult Group, UAB
