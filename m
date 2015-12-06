From: Stefan Priebe <s.priebe@profihost.ag>
Subject: Re: Asterisk deadlocks since Kernel 4.1
Date: Sun, 6 Dec 2015 21:56:34 +0100
Message-ID: <5664A102.2030602@profihost.ag>
References: <564DB5F5.9060208@profihost.ag>
 <1447936902.1986892.444251921.3928A049@webmail.messagingengine.com>
 <564DC4A5.70104@profihost.ag> <564DCC4C.1090009@redhat.com>
 <564E2852.8000200@profihost.ag> <56530A42.6030609@profihost.ag>
 <1448283451.4019628.447573353.3659E447@webmail.messagingengine.com>
 <565EBDC1.1090808@profihost.ag> <8737vlt6xb.fsf@stressinduktion.org>
 <5661DAC4.8040909@profihost.ag> <20151205010819.GA21889@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Florian Weimer <fweimer@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-kernel@vger.kernel.org,
	jannik Winkel <j.winkel@profihost.ag>,
	Marco Schinkel <m.schinkel@profihost.ag>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20151205010819.GA21889@gondor.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

i think i found the issue in 4.1 with netlink. Somebody made a mistake 
while backporting or cherry-picking your patch "netlink: Fix autobind 
race condition that leads to zero port ID" to 4.1.

It misses a goto in 4.1.

This goto is missing in 4.1:

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 4017e12..f15c001 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1132,7 +1132,6 @@ static int netlink_insert(struct sock *sk, u32 portid)
                 if (err == -EEXIST)
                         err = -EADDRINUSE;
                 sock_put(sk);
-               goto err;
         }

         /* We need to ensure that the socket is hashed and visible. */

Can you please confirm, that this is not correct and might cause those 
issues.

Stefan

Am 05.12.2015 um 02:08 schrieb Herbert Xu:
> On Fri, Dec 04, 2015 at 07:26:12PM +0100, Stefan Priebe wrote:
>>
>> * 9f87e0c - (2 months ago) netlink: Replace rhash_portid with bound
>> - Herbert Xu
>> * 35e9890 - (3 months ago) netlink: Fix autobind race condition that
>> leads to zero port ID - Herbert Xu
>> * 30c6472 - (7 months ago) netlink: Use random autobind rover - Herbert Xu
>
> These three patches are absolutely required in any kernel where the
> netlink insertion is lockless.  So yes they should be applied to
> 4.1.
>
> Thanks,
>
