From: Simon Kelley <simon-xn1N/tgparsycpQjotevgVpr/1R2p/CL@public.gmane.org>
Subject: Re: [Babel-users] Looping in EAGAIN
Date: Fri, 27 Mar 2015 11:36:38 +0000
Message-ID: <551540C6.6070500@thekelleys.org.uk>
References: <CAA93jw7Ch2B4nw-5obw7VfTUYU1kjJ9=6BkqFf4B96uWqZvPOw@mail.gmail.com>	<87egu9f5u5.wl-jch@pps.univ-paris-diderot.fr>	<877g01f3pl.wl-jch@pps.univ-paris-diderot.fr>
 <CAA93jw5mKR5hdZjSw+j3TJ1r2ARiYK5DAqW_jmk+9hp2nZehOA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: dnsmasq-discuss <Dnsmasq-discuss-YFzxfK+dQ3ZKxzGo0kwUX62ZND6+EDdj@public.gmane.org>,
 "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
 "babel-users-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org" <babel-users-XbBxUvOt3X2LieD7tvxI8l/i77bcL1HB@public.gmane.org>
To: Dave Taht <dave.taht-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
 Juliusz Chroboczek <jch-InGYJPFgxhmQrp73wey5nH9PKDog5E0sUBSOeVevoDU@public.gmane.org>
Return-path: <dnsmasq-discuss-bounces-YFzxfK+dQ3ZKxzGo0kwUX62ZND6+EDdj@public.gmane.org>
In-Reply-To: <CAA93jw5mKR5hdZjSw+j3TJ1r2ARiYK5DAqW_jmk+9hp2nZehOA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <http://lists.thekelleys.org.uk/mailman/options/dnsmasq-discuss>,
 <mailto:dnsmasq-discuss-request-YFzxfK+dQ3ZKxzGo0kwUX62ZND6+EDdj@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.thekelleys.org.uk/pipermail/dnsmasq-discuss/>
List-Post: <mailto:dnsmasq-discuss-YFzxfK+dQ3ZKxzGo0kwUX62ZND6+EDdj@public.gmane.org>
List-Help: <mailto:dnsmasq-discuss-request-YFzxfK+dQ3ZKxzGo0kwUX62ZND6+EDdj@public.gmane.org?subject=help>
List-Subscribe: <http://lists.thekelleys.org.uk/mailman/listinfo/dnsmasq-discuss>,
 <mailto:dnsmasq-discuss-request-YFzxfK+dQ3ZKxzGo0kwUX62ZND6+EDdj@public.gmane.org?subject=subscribe>
Errors-To: dnsmasq-discuss-bounces-YFzxfK+dQ3ZKxzGo0kwUX62ZND6+EDdj@public.gmane.org
Sender: "Dnsmasq-discuss" <dnsmasq-discuss-bounces-YFzxfK+dQ3ZKxzGo0kwUX62ZND6+EDdj@public.gmane.org>
List-Id: netdev.vger.kernel.org

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

dnsmasq loops awaiting a return other than EAGAIN for at most one
second, then logs an error and gives up. (The initial version of the
fix could give up in much less than one second, under certain rare
circumstances, that's fixed in 2.73rc1.)



Cheers,


Simon.


On 27/03/15 02:55, Dave Taht wrote:
> I see this patch for EAGAIN on an interface going away did not make
> the babel-ss-merge branch apparently.  (for those new to this bug,
> see: 
> http://lists.alioth.debian.org/pipermail/babel-users/2014-October/0017
77.html
>
> 
for more details. )
> 
> No, I haven't had time to test this patch, nor have I come up with
> a better idea.
> 
> I am curious if there could be some other *more robust* means of
> detecting when an interface has gone away, and/or how dnsmasq was
> coping with this situation nowadays.
> 
> (I'd mentioned this problem on the endless homenet thread
> 
> http://www.ietf.org/mail-archive/web/homenet/current/msg05156.html
> 
> and, thought I'd check to see if it was mainlined!)
> 
> I certainly hate any possibility anywhere in routing code where a 
> possibility for infinite loop existed. are there any checkers for
> such loops in the world?
> 
> On Wed, Oct 15, 2014 at 2:00 PM, Juliusz Chroboczek < 
> jch-InGYJPFgxhmQrp73wey5nH9PKDog5E0sUBSOeVevoDU@public.gmane.org> wrote:
>> Dave,
>> 
>> I'm not going to have time to test this for a while.  In the
>> meantime, here's a proposed patch, please let me know if you find
>> the time to test it. have -- Juliusz
>> 
>> diff --git a/net.c b/net.c index 6f9728f..9b0b738 100644 ---
>> a/net.c +++ b/net.c @@ -141,7 +141,7 @@ babel_send(int s, { 
>> struct iovec iovec[2]; struct msghdr msg; -    int rc; +    int
>> rc, count = 0;
>> 
>> iovec[0].iov_base = (void*)buf1; iovec[0].iov_len = buflen1; @@
>> -156,13 +156,18 @@ babel_send(int s, again: rc = sendmsg(s, &msg,
>> 0); if(rc < 0) { -        if(errno == EINTR) -            goto
>> again; -        else if(errno == EAGAIN) { +        if(errno ==
>> EINTR) { +            count++; +            if(count < 1000) +
>> goto again; +        } else if(errno == EAGAIN) { int rc2; rc2 =
>> wait_for_fd(1, s, 5); -            if(rc2 > 0) -
>> goto again; +            if(rc2 > 0) { +                count++; 
>> +                if(count < 1000) +                    goto
>> again; +            } errno = EAGAIN; } }
> 
> 
> 

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iEYEARECAAYFAlUVQMYACgkQKPyGmiibgrcS5gCfR33LxmCLH0XGyUZJn7uVNrmf
6CoAn229oPy6L/x5UuwziB5ODxGdBDUS
=9tMC
-----END PGP SIGNATURE-----
