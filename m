From: Dan Williams <dcbw@redhat.com>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 15:36:27 -0400
Message-ID: <1149708987.2625.114.camel@localhost.localdomain>
References: <4485D66B.7080108@lwfinger.net>
	 <1149682213.3999.14.camel@johannes> <4486F513.5050906@lwfinger.net>
	 <1149695470.3925.7.camel@johannes> <1149695859.3925.11.camel@johannes>
	 <1149701352.2625.20.camel@localhost.localdomain>
	 <44871723.3040803@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Johannes Berg <johannes@sipsolutions.net>, netdev@vger.kernel.org,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:40089 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932385AbWFGTgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 15:36:13 -0400
To: Larry Finger <Larry.Finger@lwfinger.net>
In-Reply-To: <44871723.3040803@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-07 at 13:12 -0500, Larry Finger wrote:
> Dan Williams wrote:
> > 
> > from ieee80211softmac_wx.c: ieee80211softmac_wx_set_genie()
> > 
> >                 memcpy(mac->wpa.IE, extra, wrqu->data.length);
> >                 dprintk(KERN_INFO PFX "generic IE set to ");
> >                 for (i=0;i<wrqu->data.length;i++)
> >                         dprintk("%.2x", mac->wpa.IE[i]);
> >                 dprintk("\n");
> > 
> > the dprintk code isn't doing the right thing here, given an array of
> > bytes.  You probably want:
> > 
> >                         dprintk("%.2hhx", mac->wpa.IE[i]);
> > 
> > (ie, add the "hh" before the x to tell the print that it's a char)
> > 
> That doesn't work - the result is

Weird, does the kernel not do something that fprintf() _does_ do here?
I tested with a short C program that mimics the behavior of this chunk
of code, and "%.2x" didn't work, but "%.2hhx" certainly did.  "hh" is
supposed to mean "A following integer conversion corresponds to a signed
char or unsigned char argument".  The original conversion was converting
stuff from la-la land after the first 4 bytes (in both softmac and my
testcase), and "hh" solved it in the testcase.  I did try casting to
char, but glibc pretty much ignored that.

Dan

> %hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx%hx
> 
> I changed the line to cast the output byte as a u8 as follows:
> 
>                          dprintk("%.2x", (u8)mac->wpa.IE[i]);
> 
> This produces the line
> 
> generic IE set to dd160050f20101000050f20201000050f20201000050f202
> 
> This is the WPA IE supplied by wpa_supplicant and it matches the one used in the ndiswrapper case. 
> One mystery solved, but why doesn't it work?
> 
> Johannes - should I submit the patch to fix this printout, or would you like to do it?
> 
> Larry

