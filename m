From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 06 Jan 2006 18:19:15 +0100
Message-ID: <43BEA693.5010509@cosmosbay.com>
References: <20060105235845.967478000@sorel.sous-sol.org> <20060106004555.GD25207@sorel.sous-sol.org> <Pine.LNX.4.64.0601051727070.3169@g5.osdl.org> <43BE43B6.3010105@cosmosbay.com> <1136554632.30498.7.camel@localhost.localdomain> <20060106164702.GA5087@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Linus Torvalds <torvalds@osdl.org>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752501AbWAFRXl@vger.kernel.org>
To: paulmck@us.ibm.com
In-Reply-To: <20060106164702.GA5087@us.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Paul E. McKenney a =E9crit :
> On Fri, Jan 06, 2006 at 01:37:12PM +0000, Alan Cox wrote:
>> On Gwe, 2006-01-06 at 11:17 +0100, Eric Dumazet wrote:
>>> I assume that if a CPU queued 10.000 items in its RCU queue, then t=
he oldest=20
>>> entry cannot still be in use by another CPU. This might sounds as a=
 violation=20
>>> of RCU rules, (I'm not an RCU expert) but seems quite reasonable.
>> Fixing the real problem in the routing code would be the real fix.=20
>>
>> The underlying problem of RCU and memory usage could be solved more
>> safely by making sure that the sleeping memory allocator path always
>> waits until at least one RCU cleanup has occurred after it fails an
>> allocation before it starts trying harder. That ought to also natura=
lly
>> throttle memory consumers more in the situation which is the right
>> behaviour.
>=20
> A quick look at rt_garbage_collect() leads me to believe that althoug=
h
> the IP route cache does try to limit its use of memory, it does not
> fully account for memory that it has released to RCU, but that RCU ha=
s
> not yet freed due to a grace period not having elapsed.
>=20
> The following appears to be possible:
>=20
> 1.	rt_garbage_collect() sees that there are too many entries,
> 	and sets "goal" to the number to free up, based on a
> 	computed "equilibrium" value.
>=20
> 2.	The number of entries is (correctly) decremented only when
> 	the corresponding RCU callback is invoked, which actually
> 	frees the entry.
>=20
> 3.	Between the time that rt_garbage_collect() is invoked the
> 	first time and when the RCU grace period ends, rt_garbage_collect()
> 	is invoked again.  It still sees too many entries (since
> 	RCU has not yet freed the ones released by the earlier
> 	invocation in step (1) above), so frees a bunch more.
>=20
> 4.	Packets routed now miss the route cache, because the corresponding
> 	entries are waiting for a grace period, slowing the system down.
> 	Therefore, even more entries are freed to make room for new
> 	entries corresponding to the new packets.
>=20
> If my (likely quite naive) reading of the IP route cache code is corr=
ect,
> it would be possible to end up in a steady state with most of the ent=
ries
> always being in RCU rather than in the route cache.
>=20
> Eric, could this be what is happening to your system?
>=20
> If it is, one straightforward fix would be to keep a count of the num=
ber
> of route-cache entries waiting on RCU, and for rt_garbage_collect()
> to subtract this number of entries from its goal.  Does this make sen=
se?
>=20

Hi Paul

Thanks for reviewing route code :)

As I said, the problem comes from 'route flush cache', that is periodic=
ally=20
done by rt_run_flush(), triggered by rt_flush_timer.

The 10% of LOWMEM ram that was used by route-cache entries are pushed i=
nto rcu=20
queues (with call_rcu_bh()) and network continue to receive
packets from *many* sources that want their route-cache entry.


Eric
