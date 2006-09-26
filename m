From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 09/11] b44: fix eeprom endianess issue
Date: Tue, 26 Sep 2006 11:59:28 -0400
Message-ID: <45194E60.4010701@garzik.org>
References: <200609252339.k8PNdNE4002654@shell0.pdx.osdl.net> <45186D66.1000508@garzik.org> <200609261747.25575.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Gary Zambrano <zambrano@broadcom.com>,
	akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:8325 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932158AbWIZP7b (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2006 11:59:31 -0400
To: Michael Buesch <mb@bu3sch.de>
In-Reply-To: <200609261747.25575.mb@bu3sch.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Michael Buesch wrote:
> On Tuesday 26 September 2006 01:59, Jeff Garzik wrote:
>> akpm@osdl.org wrote:
>>> From: Michael Buesch <mb@bu3sch.de>
>>>
>>> This fixes eeprom read on big-endian architectures.
>>>
>>> Signed-off-by: Michael Buesch <mb@bu3sch.de>
>>> Cc: Jeff Garzik <jeff@garzik.org>
>>> Signed-off-by: Andrew Morton <akpm@osdl.org>
>>> ---
>>>
>>>  drivers/net/b44.c |    2 +-
>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff -puN drivers/net/b44.c~b44-fix-eeprom-endianess-issue drivers/net/b44.c
>>> --- a/drivers/net/b44.c~b44-fix-eeprom-endianess-issue
>>> +++ a/drivers/net/b44.c
>>> @@ -2055,7 +2055,7 @@ static int b44_read_eeprom(struct b44 *b
>>>  	u16 *ptr = (u16 *) data;
>>>  
>>>  	for (i = 0; i < 128; i += 2)
>>> -		ptr[i / 2] = readw(bp->regs + 4096 + i);
>>> +		ptr[i / 2] = cpu_to_le16(readw(bp->regs + 4096 + i));
>> Seems highly silly to me:  readw() already swaps on big endian, so 
>> you're just swapping again.  And then...  read the call of 
>> b44_read_eeprom():  bp->dev->dev_addr[] assignment is such that it swaps 
>> YET AGAIN.
>>
>> Seems like a better solution would be to remove the manual swap from the 
>> caller of b44_read_eeprom().
> 
> I already explained this to you, but I will repeat me.
> readw returns the data in CPU order.
> With cpu_to_le16 we convert it to little endian, because
> "ptr" is a pointer to a _byte_ arrray. See the cast above.
> A byte array is little endian.
> Should I go into deeper detail, or did you get it? ;)
> 
> The dev_addr assignment _intentionally_ swaps yet again, because
> the values are stored in bigendian format in the SPROM.
> 
> Removing the swap for dev_addr would definately the worse and wrong
> solution.

AFAICS it's an obviously-correct end result, with far fewer swaps to boot.

	Jeff



