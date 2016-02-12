From: Rainer Weikusat <rweikusat@mobileactivedefense.com>
Subject: Re: [PATCH net] af_unix: Guard against other == sk in unix_dgram_sendmsg
Date: Fri, 12 Feb 2016 20:17:31 +0000
Message-ID: <87egchadk4.fsf@doppelsaurus.mobileactivedefense.com>
References: <56B4BF9D.9070609@pmhahn.de> <56BC90E7.7040007@pmhahn.de>
	<87fuwzkzr5.fsf@doppelsaurus.mobileactivedefense.com>
	<1455210224.2801.21.camel@decadent.org.uk>
	<87r3gjjgbu.fsf@doppelsaurus.mobileactivedefense.com>
	<87egcjcd5j.fsf@doppelsaurus.mobileactivedefense.com>
	<87r3gj11jc.fsf_-_@doppelsaurus.mobileactivedefense.com>
	<56BDA3A8.6070807@pmhahn.de>
	<8760xuvz5w.fsf@doppelsaurus.mobileactivedefense.com>
	<1455306847.2801.45.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Philipp Hahn <pmhahn@pmhahn.de>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Sasha Levin <sasha.levin@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, Karolin Seeger <kseeger@samba.org>,
	Jason Baron <jbaron@akamai.com>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Arvid Requate <requate@univention.de>,
	Stefan Gohmann <gohmann@univention.de>, netdev@vger.kernel.org
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455306847.2801.45.camel@decadent.org.uk> (Ben Hutchings's
	message of "Fri, 12 Feb 2016 19:54:07 +0000")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ben Hutchings <ben@decadent.org.uk> writes:
> On Fri, 2016-02-12 at 13:25 +0000, Rainer Weikusat wrote:
>> Philipp Hahn <pmhahn@pmhahn.de> writes:
>> > Hello Rainer,
>> > 
>> > Am 11.02.2016 um 20:37 schrieb Rainer Weikusat:
>> > > The unix_dgram_sendmsg routine use the following test
>> > > 
>> > > if (unlikely(unix_peer(other) != sk && unix_recvq_full(other))) {
>> 
>> [...]
>> 
>> > > This isn't correct as the> specified address could have been bound to
>> > > the sending socket itself
>> 
>> [...]
>> 
>> > After applying that patch at least my machine running the samba test no
>> > longer crashes.
>> 
>> There's a possible gotcha in there: Send-to-self used to be limited by
>> the queue limit. But the rationale for that (IIRC) was that someone
>> could keep using newly created sockets to queue ever more data to a
>> single, unrelated receiver. I don't think this should apply when
>> receiving and sending sockets are identical. But that's just my
>> opinion. The other option would be to avoid the unix_state_double_lock
>> for sk == other.
>
> Given that unix_state_double_lock() already handles sk == other, I'm
> not sure why you think it needs to be avoided.

Because the whole complication of restarting the operation after locking
both sk and other because other had to be unlocked before calling
unix_state_double_lock is useless for this case: As other == sk, there's
no reason to drop the lock on it which guarantees that the result of all
the earlier checks is still valid: If the -EAGAIN condition is not true,
execution can just continue.

>> I'd be willing to change this accordingly if someone
>> thinks the queue limit should apply to send-to-self.
>
> If we don't check the queue limit here, does anything else prevent the
> queue growing to the point it's a DoS?

The max_dgram_qlen limit exists specifically to prevent someone sending
'a lot' of messages to a socket unrelated to it by repeatedly creating a
socket, sending as many messages as the send buffer size will allow,
closing the socket, creating a new socket, ..., cf

http://netdev.vger.kernel.narkive.com/tcZIFJeC/get-rid-of-proc-sys-net-unix-max-dgram-qlen#post4
(first copy I found)

This 'attack' will obviously not work very well when sending and
receiving socket are identical.
