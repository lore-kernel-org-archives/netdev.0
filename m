From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
 <yoshfuji@wide.ad.jp>
Subject: Re: IPsecv6 integrity failures not dropped
Date: Sat, 19 Apr 2003 11:12:38 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030419.111238.07385967.yoshfuji@wide.ad.jp>
References: <200304182017.h3IKH4ng019821@faith.austin.ibm.com>
	<20030418.141014.17269641.davem@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: latten@austin.ibm.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   linux-kernel@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
To: davem@redhat.com
In-Reply-To: <20030418.141014.17269641.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <20030418.141014.17269641.davem@redhat.com> (at Fri, 18 Apr 2003 14:10:14 -0700 (PDT)), "David S. Miller" <davem@redhat.com> says:

> I think it would be better if ipv6's upper-layer interface worked
> like ipv4's.  ie. a < 0 return value means:
> 
> 	next_proto =- ret;
> 	goto resubmit;

NO!  Please, don't do this again (for now, at least).
This idea is what we had introduced the bug,
that was fixed by "[IPV6]: Fixed multiple mistake extension header handling."

We need to get the offset of the next header, in addition to the value
itself.

inet6_protocol function will return:

  > 0: more header(s) follows; next header is pointed by skb->nh.raw[nhoff]
  = 0: stop parsing on success; increment the statistics (nhoff is undefined)
  < 0: stop parsing on failure (nhoff is undefined)

If upper-layer returns positive value, we continue parsing.
Then, if the skb->nh.raw[nhoff] is unknown, we send back the parameter problem 
message with the offset to the unrecognized next header field.


> The less that is different between ipv4/ipv6 the better.

Agreed, but please note that IPv4 side would be required to be changed
in general.


Well... 

1) May we have a new member to point the offset of the next header in 
   ipv6_pinfo{}?
   Then, we can remove *nhoffp from argument of inet6_protocol function.
   (We will be cleaner handing of HbH option, too.)
2) change IPv4 upperlayer function to take struct sk_buff **.


If you are not in hurry, I'll take care of this.

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
