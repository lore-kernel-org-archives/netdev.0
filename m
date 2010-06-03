From: "Paoloni, Gabriele" <gabriele.paoloni@intel.com>
Subject: RE: [PATCH] ppp_generic: fix multilink fragment sizes
Date: Thu, 3 Jun 2010 09:41:59 +0100
Message-ID: <DF7BB929B28FCF479E888E3D9F8D9E88D3E1706A@irsmsx502.ger.corp.intel.com>
References: <4C0670E2.1090708@netservers.co.uk>
 <1275491094-9526-1-git-send-email-ben@netservers.co.uk>
 <DF7BB929B28FCF479E888E3D9F8D9E88D3E16B5A@irsmsx502.ger.corp.intel.com>
 <4C067EF7.9040609@netservers.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"alan@lxorguk.ukuu.org.uk" <alan@lxorguk.ukuu.org.uk>,
	"linux-ppp@vger.kernel.org" <linux-ppp@vger.kernel.org>,
	"paulus@samba.org" <paulus@samba.org>
To: Ben McKeegan <ben@netservers.co.uk>
Return-path: <linux-ppp-owner@vger.kernel.org>
In-Reply-To: <4C067EF7.9040609@netservers.co.uk>
Content-Language: en-US
Sender: linux-ppp-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

I agree with you about replacing totlen with len (actually the previous one was quite bad).
I think we don't need to round up anyway and nbigger is doing his job I think. Basically we are giving just one more byte to the first nbigger free channels and for the rest the integer division will round down automatically.

For example say you have before transmitting 5 free channels and len is 83bytes

nbigger will be (ln 1284) 83%5=3

the frame will be split as follows: 17 - 17 - 17 - 16 - 16

Since for the first three iterations the channel to tx on will get an extra byte (ln1427) and nbigger will be decreased by one (ln1428).

The only change I would make to the code is to replace totlen with len @ln1425

Now if you agree either me or you can submit a new patch.

Regards

Gabriele Paoloni   

>-----Original Message-----
>From: Ben McKeegan [mailto:ben@netservers.co.uk]
>Sent: 02 June 2010 16:56
>To: Paoloni, Gabriele
>Cc: davem@davemloft.net; netdev@vger.kernel.org; linux-
>kernel@vger.kernel.org; alan@lxorguk.ukuu.org.uk; linux-
>ppp@vger.kernel.org; paulus@samba.org
>Subject: Re: [PATCH] ppp_generic: fix multilink fragment sizes
>
>Paoloni, Gabriele wrote:
>> The proposed patch looks wrong to me.
>>
>> nbigger is already doing the job; I didn't use DIV_ROUND_UP because in
>general we don't have always to roundup, otherwise we would exceed the
>total bandwidth.
>
>I was basing this on the original code prior to your patch, which used
>DIV_ROUND_UP to get the fragment size.  Looking more closely I see your
>point, the original code was starting with the larger fragment size and
>decrementing rather than starting with the smaller size and incrementing
>as your code does, so that makes sense.
>
>
>>
>>  		flen = len;
>>  		if (nfree > 0) {
>>  			if (pch->speed == 0) {
>> -				flen = totlen/nfree;
>> +				if (nfree > 1)
>> +					flen = DIV_ROUND_UP(len, nfree);
>>  				if (nbigger > 0) {
>>  					flen++;
>>  					nbigger--;
>
>The important change here is the use of 'len' instead of 'totlen'.
>'nfree' and 'len' should decrease roughly proportionally with each
>iteration of the loop whereas 'totlen' remains unchanged.  Thus
>(totlen/nfree) gets bigger on each iteration whereas len/nfree should
>give roughly the same.  However, without rounding up here I'm not sure
>the logic is right either, since the side effect of nbigger is to make
>len decrease faster so it is not quite proportional to the decrease in
>nfree.  Is there a risk of ending up on the nfree == 1 iteration with
>flen == len - 1 and thus generating a superfluous extra 1 byte long
>fragment?  This would be a far worse situation than a slight imbalance
>in the size of the fragments.
>
>Perhaps the solution is to go back to a precalculated fragment size for
>the pch->speed == 0 case as per original code?
>
>Regards,
>Ben.
--------------------------------------------------------------
Intel Shannon Limited
Registered in Ireland
Registered Office: Collinstown Industrial Park, Leixlip, County Kildare
Registered Number: 308263
Business address: Dromore House, East Park, Shannon, Co. Clare

This e-mail and any attachments may contain confidential material for the sole use of the intended recipient(s). Any review or distribution by others is strictly prohibited. If you are not the intended recipient, please contact the sender and delete all copies.


