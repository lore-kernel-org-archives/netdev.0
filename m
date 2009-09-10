From: Brian Haley <brian.haley@hp.com>
Subject: Re: [PATCH] ipv6: Add IFA_F_DADFAILED flag
Date: Thu, 10 Sep 2009 15:14:22 -0400
Message-ID: <4AA9500E.8020309@hp.com>
References: <4AA1C0FF.4030109@hp.com> <1252418247.5827.8.camel@fnki-nb00130>	 <4AA675D4.8030406@hp.com> <1252424623.5827.14.camel@fnki-nb00130>	 <4AA84B3C.4000401@hp.com> <1252599080.5980.3.camel@fnki-nb00130>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: david Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
To: Jens Rosenboom <me@jayr.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0029.austin.hp.com ([15.216.28.36]:44318 "EHLO
	g1t0029.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752642AbZIJTOW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Sep 2009 15:14:22 -0400
In-Reply-To: <1252599080.5980.3.camel@fnki-nb00130>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Jens,

Jens Rosenboom wrote:
>> Ok, how does this look?  I changed it to set the tentative flag as it did
>> before, plus clear the dad_failed flag if the device got restarted,
>> triggering DAD to happen again for any tentative address, that was an
>> oversight on my part.
> 
> Looks fine to me so far, can you also send the patch for userspace? That
> would making testing this a bit easier. ;-)

Iproute2 patch below, I'll re-post both once you have a chance to test.

>> I'd still like to know if using this last ifa_flag is going to be an issue,
>> I actually finished a similar patch that uses a new IFA_ADDRFLAGS structure
>> to pass in/out this additional info.
> 
> IMHO you should stick to this version, if any future feature needs
> another bit, it may happen also to need two of them and so will need a
> new structure then anyway, but why not keep it simple for now?

I'll leave it for now, I might just post as an RFC to get some feedback on it.

Thanks,

-Brian


diff --git a/include/linux/if_addr.h b/include/linux/if_addr.h
index a60c821..fd97404 100644
--- a/include/linux/if_addr.h
+++ b/include/linux/if_addr.h
@@ -41,6 +41,7 @@ enum
 
 #define	IFA_F_NODAD		0x02
 #define IFA_F_OPTIMISTIC	0x04
+#define IFA_F_DADFAILED		0x08
 #define	IFA_F_HOMEADDRESS	0x10
 #define IFA_F_DEPRECATED	0x20
 #define IFA_F_TENTATIVE		0x40
diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 267ecb3..97c7a8b 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -508,6 +508,10 @@ int print_addrinfo(const struct sockaddr_nl *who, struct nlmsghdr *n,
 		fprintf(fp, "dynamic ");
 	} else
 		ifa->ifa_flags &= ~IFA_F_PERMANENT;
+	if (ifa->ifa_flags&IFA_F_DADFAILED) {
+		ifa->ifa_flags &= ~IFA_F_DADFAILED;
+		fprintf(fp, "dadfailed ");
+	}
 	if (ifa->ifa_flags)
 		fprintf(fp, "flags %02x ", ifa->ifa_flags);
 	if (rta_tb[IFA_LABEL])
