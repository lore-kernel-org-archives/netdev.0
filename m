From: Dan Williams <dcbw@redhat.com>
Subject: Re: Problem authenticating using WPA with bcm43xx-softmac
Date: Wed, 07 Jun 2006 13:29:12 -0400
Message-ID: <1149701352.2625.20.camel@localhost.localdomain>
References: <4485D66B.7080108@lwfinger.net>
	 <1149682213.3999.14.camel@johannes>  <4486F513.5050906@lwfinger.net>
	 <1149695470.3925.7.camel@johannes>  <1149695859.3925.11.camel@johannes>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Larry Finger <Larry.Finger@lwfinger.net>, netdev@vger.kernel.org,
	Jouni Malinen <jkm@devicescape.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:23209 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S932359AbWFGR3H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Jun 2006 13:29:07 -0400
To: Johannes Berg <johannes@sipsolutions.net>
In-Reply-To: <1149695859.3925.11.camel@johannes>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-06-07 at 17:57 +0200, Johannes Berg wrote:
> On Wed, 2006-06-07 at 17:51 +0200, Johannes Berg wrote:
> 
> > Well, it should be shown in the 802.11i spec too.
> 
> I suppose that it is the association request, and needs to contain the
> RSN described in 7.3.2.25 as per 7.2.3.4 in 802.11i. This is, afaik, the
> 'generic IE' that is added with the wext. Now, it looks like the RSN
> isn't included but the WPA2 info or something? Also, the genIE in your
> log doesn't look correct to me, starting with ffffff?? Jouni, do you
> have any idea what might be going on?

I believe that wpa_supplicant tells the driver what genie to use through
the SIOCSIWGENIE wext call.  The IEs match between what the driver
appears to be reporting, and what wpa_supplicant says from the logs.
wpa_supplicant is almost certainly writing the correct IE to the driver
through wext, so I think the debug output from softmac must be
formatting the string incorrectly when printing it out to the logs.

Looking at it further:

struct ieee80211softmac_wpa {
        char *IE;
        int IElen;
        int IEbuflen;
};

from ieee80211softmac_wx.c: ieee80211softmac_wx_set_genie()

                memcpy(mac->wpa.IE, extra, wrqu->data.length);
                dprintk(KERN_INFO PFX "generic IE set to ");
                for (i=0;i<wrqu->data.length;i++)
                        dprintk("%.2x", mac->wpa.IE[i]);
                dprintk("\n");

the dprintk code isn't doing the right thing here, given an array of
bytes.  You probably want:

                        dprintk("%.2hhx", mac->wpa.IE[i]);

(ie, add the "hh" before the x to tell the print that it's a char)

Dan


