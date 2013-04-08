From: Casey Schaufler <casey@schaufler-ca.com>
Subject: Re: [PATCH] tcp: assign the sock correctly to an outgoing SYNACK
 packet
Date: Mon, 08 Apr 2013 16:40:35 -0700
Message-ID: <51635573.7030706@schaufler-ca.com>
References: <3505145.vfXt1x4t0P@sifl> <20130408.171512.973275376690340387.davem@davemloft.net> <2921619.mqaHl5PnPI@sifl> <20130408.173325.1683493727549657170.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: pmoore@redhat.com, eric.dumazet@gmail.com, netdev@vger.kernel.org,
	mvadkert@redhat.com, selinux@tycho.nsa.gov,
	linux-security-module@vger.kernel.org,
	Casey Schaufler <casey@schaufler-ca.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20130408.173325.1683493727549657170.davem@davemloft.net>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4/8/2013 2:33 PM, David Miller wrote:
> From: Paul Moore <pmoore@redhat.com>
> Date: Mon, 08 Apr 2013 17:24:50 -0400
>
>> If the void pointer is wrapped by a #ifdef (plenty of precedence for that) and 
>> the management of that pointer is handled by LSM hooks why is it a concern?  I 
>> apologize for pushing on the issue, but I'm having a hard time reconciling the 
>> reason for the "no" with the comments/decisions about the regression fix; at 
>> present there seems to be a level of contradiction between the two.
> 8 bytes times however many millions of packets per second we can process
> on a big machine, you do the math.

OK, let's do the math.

First off, it's 4 bytes, not 8. It replaces the secmark.
Your increased memory usage is going to be

	4 bytes/packet *  M packets/second * N seconds

Where M is the rate at which you're processing packets and
N is the length of time it takes to process a packet.

Let's pretend we have an embedded system that does nothing but send
128 byte packets on a 10Gb port. That's 10M packets/second. If it
takes a full second to process a packet the overhead is 40MB for that
second. I have it on good authority that packets can be processed
in considerably less time than that. The real number is more like
0.05 seconds. That means your actual overhead is more like 1MB.

These are dumbed down calculations. I am not a memory usage expert.
I am convinced that "real" calculations are going to get similar
numbers. I am, of course, willing to be swayed by evidence that I
am wrong.

Compare that to the overhead associated with using CIPSO on packets
that never leave the box.



>
> It's memory, less cache locality, etc. etc. etc.
>
> It's the most important data structure in the entire networking stack,
> and every single byte matters.
>
> I want the overhead to be your problem, so that only users of your
> stuff eat the overhead, rather than everyone.
>
> And don't even mention ifdefs, that's bogus, because every
> distribution turns every option on, %99.9999999 of users will
> therefore not see the savings.
>
> Really, this is a dead topic, let's move on.
>
> Thanks.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-security-module" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>

