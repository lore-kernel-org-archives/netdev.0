From: jamal <hadi@cyberus.ca>
Subject: IPSEC: on behavior of acquire
Date: 01 Apr 2005 20:25:44 -0500
Message-ID: <1112405144.1096.33.camel@jzny.localdomain>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: psec-tools-devel@lists.sourceforge.net, netdev@oss.sgi.com,
        kaber@trash.net, kuznet@ms2.inr.ac.ru, jmorris@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S. Miller" <davem@davemloft.net>,
        Masahide NAKAMURA <nakam@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Folks,

Theres something wrong in the way acquire works - IMO in both pfkey
and netlink. I asked this before but didnt get satisfactory answer.
Masahide-san and myself have had private exchanges and we are both
unsatisfied with current situation. Theres probably a spec or known good
practise documented somewhere ...

Let me provide some testcases then theorize. The idea is to simulate
a situation where the kernel thinks a km is listening (it could be there
but just non-responsive) or just a scenario where the acquire gets lost.
You need the current events patches to see this.

test1)on one window run setkey -x:

ping -c 1 someDST

-1) packet arrives towards outbound
0) Larval state created
1) one acquire sent.
2) timeout.
3) packet dropped. -ESRCH returned.
4) larval state deleted

So question 1): Shouldnt the return code be -ERESTART to ask
the app to retry?
question 2) Why is there a hardcoding of 1 try only?

ping -c2 someDST
Same as above (Steps -1 to 4) repeated twice
one for each packet sent

ping -c3 DST
Same as above repeated 3 times.

test2) With ip x m (but not setkey).

ping -c 1 DST

-1) packet arrives
0) Larval state created
Loop:
1) one acquire sent.
2) timeout. go to loop.
 
So loop has no way to break. ping is hang waiting.
the only way to break out is by hitting control-c on prompt.
I think ping gets a -ERESTART which i believe is the correct signal?
When you hit control-c Larval state is deleted.

Clearly this is not desirable. We want at some point to give up.
Question: Can we have a configurable max retries (sysctl settable)
for acquire - or does it already exist just not being used? Couldnt
find any staring at the code.

ping -c2/3 DST does not change the above behavior. Ping is hang after
first packet - so it doesnt matter.

The conclusion we reached in our discussion is:
a) -ERESTART is the correct signal to return
b) number of acquire retries should be configurable preferably a system
wide value.

Thoughts?

cheers,
jamal
