From: Adrian Bunk <bunk@stusta.de>
Subject: Re: [patch 1/3] fix buggy IEEE80211_CRYPT_* selects
Date: Sat, 5 Mar 2005 00:07:18 +0100
Message-ID: <20050304230718.GL3327@stusta.de>
References: <200503041237.j24Cbb69026470@shell0.pdx.osdl.net> <42289BDF.1080409@pobox.com> <20050304221014.GJ3327@stusta.de> <4228DF62.4000205@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>, akpm@osdl.org,
        davem@davemloft.net, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <4228DF62.4000205@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Mar 04, 2005 at 05:21:22PM -0500, Jeff Garzik wrote:
> Adrian Bunk wrote:
> >On Fri, Mar 04, 2005 at 12:33:19PM -0500, Jeff Garzik wrote:
> >
> >>akpm@osdl.org wrote:
> >>
> >>>From: Adrian Bunk <bunk@stusta.de>
> >>>
> >>>Some of the options that needlessly wrote in their help text which 
> >>>options
> >>>they do select (patch already sent) didn't obey the most important rule 
> >>>of
> >>>select
> >>>
> >>>If you select something, you have to ensure that the dependencies
> >>>of what you do select are fulfilled.
> >>
> >>>diff -puN net/ieee80211/Kconfig~fix-buggy-ieee80211_crypt_-selects 
> >>>net/ieee80211/Kconfig
> >>>--- 25/net/ieee80211/Kconfig~fix-buggy-ieee80211_crypt_-selects 
> >>>2005-02-28 14:49:54.000000000 -0800
> >>>+++ 25-akpm/net/ieee80211/Kconfig	2005-02-28 14:49:54.000000000 -0800
> >>>@@ -44,6 +44,7 @@ config IEEE80211_CRYPT_WEP
> >>>config IEEE80211_CRYPT_CCMP
> >>>	tristate "IEEE 802.11i CCMP support"
> >>>	depends on IEEE80211
> >>>+	select CRYPTO
> >>>	select CRYPTO_AES
> >>>	---help---
> >>>	Include software based cipher suites in support of IEEE 802.11i 
> >>>@@ -56,6 +57,7 @@ config IEEE80211_CRYPT_CCMP
> >>>config IEEE80211_CRYPT_TKIP
> >>>	tristate "IEEE 802.11i TKIP encryption"
> >>>	depends on IEEE80211
> >>>+	select CRYPTO
> >>>	select CRYPTO_MICHAEL_MIC
> >>>	---help---
> >>
> >>
> >>You are resending the old patch that is incorrect.  We don't need 
> >>multiple selects, CRYPTO_AES and CRYPTO_MICHAEL_MIC should pull things in.
> >
> >
> >As I already said, this implies that options like CRYPTO_AES and 
> >CRYPTO_MICHAEL_MIC can no longer depend on CRYPTO.
> 
> No.  Because CRYPTO_AES and CRYPTO_MICHAEL_MIC __obviously__ depend on 
> CRYPTO, it should select CRYPTO automatically given the existing entries.
> 
> Otherwise, we must start specifying dependency chains in every damn 
> Kconfig entry, which is completely illogical and a maintenance nightmare.

The way kconfig currently works, you have to ensure that the 
dependencies of what you select are fulfilled.

And handling dependencies as select chains creates some subtle problems:


Consider the following example:

config A
	tristate "foo"
	depends on !B && (C || D)

config E
	tristate "bar"
	select B

config F
	tristate "42"
	select A

With:
A=n
B=y
C=n
D=n
E=y


What values of the variables A-E do you expect exactly if the user turns 
on F?


Or even better, the code in question as a example due to the current 
confusing CRYPTO_AES dependencies (discussed in another thread and will 
be solved):

config IEEE80211_CRYPT_CCMP
        tristate "IEEE 802.11i CCMP support"
        depends on IEEE80211
        select CRYPTO_AES

config CRYPTO_AES
        tristate "AES cipher algorithms"
        depends on CRYPTO && !(X86 && !X86_64)

On i386, should your "select CRYPTO_AES" set X86=n or X86_64=y ?

This would create even nastier bugs if it was hidden somewhere in a 
dependency chain.


Some people say that you mustn't select an user-visible option - this 
way you avoid any such problems.

This would mean you weren't allowed to select CRYPTO or CRYPTO_AES or 
CRYPTO_MICHAEL_MIC.

I'm less dogmatic regarding this because I care more about the usability 
of the kernel config system than about such rules, but what you want is 
simply not possible in a reasonable way.


> 	Jeff

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed
