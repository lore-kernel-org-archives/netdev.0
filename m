From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH] Make hmac algorithm selection for cookie generation dynamic
Date: Wed, 24 Oct 2012 12:17:48 -0400
Message-ID: <508814AC.8030005@gmail.com>
References: <1350661926-8312-1-git-send-email-nhorman@tuxdriver.com> <5087FBE0.1020005@gmail.com> <20121024160157.GA26433@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sctp@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:61536 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757394Ab2JXQRw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2012 12:17:52 -0400
In-Reply-To: <20121024160157.GA26433@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/24/2012 12:01 PM, Neil Horman wrote:
> On Wed, Oct 24, 2012 at 10:32:00AM -0400, Vlad Yasevich wrote:
>> On 10/19/2012 11:52 AM, Neil Horman wrote:
>>> Currently sctp allows for the optional use of md5 of sha1 hmac algorithms to
>>> generate cookie values when establishing new connections via two build time
>>> config options.  Theres no real reason to make this a static selection.  We can
>>> add a sysctl that allows for the dynamic selection of these algorithms at run
>>> time, with the default value determined by the corresponding crypto library
>>> config options.  It saves us two needless configuration settings and enables the
>>> freedom for administrators to select which algorithm a particular system uses.
>>> This comes in handy when, for example running a system in FIPS mode, where use
>>> of md5 is disallowed, but SHA1 is permitted.
>>>
>>> Note: This new sysctl has no corresponding socket option to select the cookie
>>> hmac algorithm.  I chose not to implement that intentionally, as RFC 6458
>>> contains no option for this value, and I opted not to pollute the socket option
>>> namespace.
>>>
>>> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>>> CC: Vlad Yasevich <vyasevich@gmail.com>
>>> CC: "David S. Miller" <davem@davemloft.net>
>>> CC: netdev@vger.kernel.org
>>> ---
>>>   Documentation/networking/ip-sysctl.txt | 14 ++++++++
>>>   include/net/netns/sctp.h               |  3 ++
>>>   include/net/sctp/constants.h           |  8 -----
>>>   include/net/sctp/structs.h             |  1 +
>>>   net/sctp/Kconfig                       | 30 -----------------
>>>   net/sctp/protocol.c                    |  9 ++++++
>>>   net/sctp/socket.c                      | 11 ++++---
>>>   net/sctp/sysctl.c                      | 59 ++++++++++++++++++++++++++++++++++
>>>   8 files changed, 93 insertions(+), 42 deletions(-)
>>>
>>> diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
>>> index c7fc107..98ac0d7 100644
>>> --- a/Documentation/networking/ip-sysctl.txt
>>> +++ b/Documentation/networking/ip-sysctl.txt
>>> @@ -1514,6 +1514,20 @@ cookie_preserve_enable - BOOLEAN
>>>
>>>   	Default: 1
>>>
>>> +cookie_hmac_alg - STRING
>>> +	Select the hmac algorithm used when generating the cookie value sent by
>>> +	a listening sctp socket to a connecting client in the INIT-ACK chunk.
>>> +	Valid values are:
>>> +	* md5
>>> +	* sha1
>>> +	* none
>>> +	Ability to assign md5 or sha1 as the selected alg is predicated on the
>>> +	configuarion of those algorithms at build time (CONFIG_CRYPTO_MD5 and
>>> +	CONFIG_CRYPTO_SHA1).
>>> +
>>> +	Default: Dependent on configuration.  MD5 if available, else SHA1 if
>>> +	available, else none.
>>> +
>>>   rcvbuf_policy - INTEGER
>>>   	Determines if the receive buffer is attributed to the socket or to
>>>   	association.   SCTP supports the capability to create multiple
>>> diff --git a/include/net/netns/sctp.h b/include/net/netns/sctp.h
>>> index 5e5eb1f..3573a81 100644
>>> --- a/include/net/netns/sctp.h
>>> +++ b/include/net/netns/sctp.h
>>> @@ -62,6 +62,9 @@ struct netns_sctp {
>>>   	/* Whether Cookie Preservative is enabled(1) or not(0) */
>>>   	int cookie_preserve_enable;
>>>
>>> +	/* The namespace default hmac alg */
>>> +	char *sctp_hmac_alg;
>>> +
>>>   	/* Valid.Cookie.Life	    - 60  seconds  */
>>>   	unsigned int valid_cookie_life;
>>>
>>> diff --git a/include/net/sctp/constants.h b/include/net/sctp/constants.h
>>> index d053d2e..c29707d 100644
>>> --- a/include/net/sctp/constants.h
>>> +++ b/include/net/sctp/constants.h
>>> @@ -312,14 +312,6 @@ enum { SCTP_MAX_GABS = 16 };
>>>   				 * functions simpler to write.
>>>   				 */
>>>
>>> -#if defined (CONFIG_SCTP_HMAC_MD5)
>>> -#define SCTP_COOKIE_HMAC_ALG "hmac(md5)"
>>> -#elif defined (CONFIG_SCTP_HMAC_SHA1)
>>> -#define SCTP_COOKIE_HMAC_ALG "hmac(sha1)"
>>> -#else
>>> -#define SCTP_COOKIE_HMAC_ALG NULL
>>> -#endif
>>> -
>>>   /* These return values describe the success or failure of a number of
>>>    * routines which form the lower interface to SCTP_outqueue.
>>>    */
>>> diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
>>> index 0fef00f..ce5f957 100644
>>> --- a/include/net/sctp/structs.h
>>> +++ b/include/net/sctp/structs.h
>>> @@ -177,6 +177,7 @@ struct sctp_sock {
>>>
>>>   	/* Access to HMAC transform. */
>>>   	struct crypto_hash *hmac;
>>> +	char *sctp_hmac_alg;
>>>
>>>   	/* What is our base endpointer? */
>>>   	struct sctp_endpoint *ep;
>>> diff --git a/net/sctp/Kconfig b/net/sctp/Kconfig
>>> index 126b014..44ffd3e 100644
>>> --- a/net/sctp/Kconfig
>>> +++ b/net/sctp/Kconfig
>>> @@ -9,7 +9,6 @@ menuconfig IP_SCTP
>>>   	select CRYPTO
>>>   	select CRYPTO_HMAC
>>>   	select CRYPTO_SHA1
>>> -	select CRYPTO_MD5 if SCTP_HMAC_MD5
>>>   	select LIBCRC32C
>>>   	---help---
>>>   	  Stream Control Transmission Protocol
>>> @@ -68,33 +67,4 @@ config SCTP_DBG_OBJCNT
>>>
>>>   	  If unsure, say N
>>>
>>> -choice
>>> -	prompt "SCTP: Cookie HMAC Algorithm"
>>> -	default SCTP_HMAC_MD5
>>
>> Did you intend to change the default algorithm to SHA1?  Seems a bit
>> unintended and undocumented.
>>
> Thats not what I did (or at least not my intention).  The sctp_net_init code
> checks teh crypto options and if md5 is selcted as on, it uses that as a
> default, only if its not selected, does sha1 become the default.  In my testing
> this worked properly, and the sysctl for the init_net came up as md5, even
> though I had both md5 and sha1 configured.  Is there something else here I'm
> missing?

Yes, if you turn on MD5 in the config, it stays the default.  However, 
if you do a brand new config, MD5 may be disabled (if nothing else in 
the config needs it) and then your default will change seemingly 
unintentionally.  You always get SHA1 because it is needed for SCTP AUTH.

>
>> Would it make more sense to to change from a choice to sub-menu and
>> allow selection of multiple algorithms?  Then use the interface you
>> have to change the default.
>>
> Not sure I follow.  You mean create a sub-menu allowing us to choose the default
> value at compile time, and allow overriding from there via sysctl? I'm fine with
> such a change, although given that everyone seems used to the idea of md5 being
> the default when configured, as well as the idea of needing to override default
> sysctl values, I'm not sure is necessecary.
>
>
> Let me know about the default, and if I'm on the same page as you regarding the
> config option, and I can repost this.
>

What I am not sure I like is that there is no longer any tie in between 
the HMACs needed for cookie signing and the HMAC module selections in 
SCTP.  You just happen to get lucky with SHA1 because it is always there 
for AUTH.  Before, to disable cookie signing, it was an explicit 
configuration choice to turn it off in the SCTP section.  Now, it might 
be an unintended side-effect for not turning on the right modules.
See what I am getting at?

A solution might be to have a sub-menu that allows you to turn on a set
of signing algorithms and may be even choose the default one.  This way 
it's clear that there is a dependency relationship between SCTP and 
signing algorithms.

-vlad

> Thanks!
> Neil
>
