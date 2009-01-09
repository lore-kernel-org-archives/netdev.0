From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] ethtool: Support arbitrary speeds
Date: Fri, 09 Jan 2009 09:55:55 -0800
Message-ID: <49678FAB.3040007@hp.com>
References: <200901080203.SAA19103@tardy.cup.hp.com>	<1231384446.2677.32.camel@hashbaz.i.decadent.org.uk>	<49656F01.3090603@pobox.com>  <49664FFD.1010608@hp.com>	<1231442701.3893.4.camel@achroite>  <496658EB.1080206@hp.com> <1231506974.3006.18.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:36720 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754442AbZAIR4B (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Jan 2009 12:56:01 -0500
In-Reply-To: <1231506974.3006.18.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> The speed and speed_hi fields of struct ethtool_cmd together represent
> a value in units of Mbit/s.  The valid speed settings are hardware-
> dependent and should be checked by the driver.  Remove our validation
> and allow arbitrary positive values.  Continue to report 0 and -1 as
> "Unknown!" since some drivers will report these invalid values when
> the link is down.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> On Thu, 2009-01-08 at 11:50 -0800, Rick Jones wrote:
> 
>>>I think 0, (u32)(-1) and (u16)(-1) may have to be special-cased as
>>>unknown, but everything else can be treated as a number of Mbit/s.  I
>>>don't know what a driver should do about an interface that really runs
>>>at 65.535 Gbit/s though...
>>
>>Something along these lines then? (assuming my mailer doesn't fubar this
>>:( - I normally send matches via mailx)
> 
> 
> That's kind of incomplete.  Here's my attempt.
> 
> In a quick test I found that the tg3 driver *doesn't* validate the speed
> setting if autonegotiation is off, and will accept and report back e.g.
> 99.  But this patch doesn't create a new problem as you could already
> set it to the unsupported speeds of 2500 and 10000.

I'm fine with yanking the vetting on set - didn't do it initially 
because what got me patching in the first place does the setting of the 
speeds "elsewhere" so set support wasn't an issue.

WRT the get part:

> @@ -893,30 +884,17 @@ static void dump_advertised(struct ethtool_cmd *ep)
>  
>  static int dump_ecmd(struct ethtool_cmd *ep)
>  {
> +	u32 speed;
> +
>  	dump_supported(ep);
>  	dump_advertised(ep);
>  
>  	fprintf(stdout, "	Speed: ");
> -	switch (ethtool_cmd_speed(ep)) {
> -	case SPEED_10:
> -		fprintf(stdout, "10Mb/s\n");
> -		break;
> -	case SPEED_100:
> -		fprintf(stdout, "100Mb/s\n");
> -		break;
> -	case SPEED_1000:
> -		fprintf(stdout, "1000Mb/s\n");
> -		break;
> -	case SPEED_2500:
> -		fprintf(stdout, "2500Mb/s\n");
> -		break;
> -	case SPEED_10000:
> -		fprintf(stdout, "10000Mb/s\n");
> -		break;
> -	default:
> -		fprintf(stdout, "Unknown! (%i)\n", ethtool_cmd_speed(ep));
> -		break;
> -	};
> +	speed = ethtool_cmd_speed(ep);
> +	if (speed == 0 || speed == (u16)(-1) || speed == (u32)(-1))
> +		fprintf(stdout, "Unknown!\n");

Doesn't that need to keep the reporting of the unknown speed in parens 
like the original?

rick jones
