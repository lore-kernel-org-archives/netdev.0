From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] [NET] socket.c: zero socket addresses
	before use.
Date: Wed, 21 Sep 2005 07:48:28 -0600
Message-ID: <m14q8efs5v.fsf@ebiederm.dsl.xmission.com>
References: <m1ek7ulyt8.fsf@ebiederm.dsl.xmission.com>
	<20050912.154527.48978091.davem@davemloft.net>
	<m1hdcfhd40.fsf_-_@ebiederm.dsl.xmission.com>
	<20050921.001321.78997430.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: openib-general@openib.org, netdev@vger.kernel.org
Return-path: <openib-general-bounces@openib.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050921.001321.78997430.davem@davemloft.net> (David S.
	Miller's message of "Wed, 21 Sep 2005 00:13:21 -0700 (PDT)")
List-Unsubscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=unsubscribe>
List-Archive: <http://openib.org/pipermail/openib-general>
List-Post: <mailto:openib-general@openib.org>
List-Help: <mailto:openib-general-request@openib.org?subject=help>
List-Subscribe: <http://openib.org/mailman/listinfo/openib-general>,
	<mailto:openib-general-request@openib.org?subject=subscribe>
Sender: openib-general-bounces@openib.org
Errors-To: openib-general-bounces@openib.org
List-Id: netdev.vger.kernel.org

"David S. Miller" <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 20 Sep 2005 11:18:23 -0600
>
>> Dave I don't know if this is part of what you want but
>> zeroing the socket address buffer before use seem to be implied
>> by what you were asking for.   So here is an additional patch
>> to implement that.
>> 
>> This is a paranoid precaution to guard against accidental
>> information leaks to user space or other consumers/producers
>> may fail to properly fail to set or read the hardware
>> address length. af_packet over ethernet has had at least
>> has one small but in this respect.
>
> I think this patch might be a bit overkill, but thanks for cooking it
> up.  I'm willing to be convinced otherwise though :-)

Personally I agree. But if we don't we probably need to audit
all of the other protocols besides af_packet and see if
they could possible have the problem that af_packet did
with struct sockaddr_ll.

What happened is struct sockaddr_ll had an array of 8 bytes
where it placed a hardware address.  It reported to socket.c
the length of struct sockaddr_ll for returning to user space.
The code then only filled in enough bytes for the actual hardware
address.  6 bytes in the common case of ethernet.  So only 6 bytes
were ever written and we returned 8 bytes to user space.

The transmission is similar except the kernel code was responsible
for simply not caring about the additional bytes.  But confused
kernel code could have the problem.

This is the same problem you were concerned about with 
my new struct packet_mreq_max.  The only way to take the same
precautions on the other code paths is to modify socket.c

I am concerned enough to point out the possibility and send
a patch to add some memset() as a cheap insurance plan.  Auditing
the address handling for all of the rest of the network protcols is
more than I am ready to volunteer for.

Eric
