From: Filipe Manco <filipe.manco@neclab.eu>
Subject: Re: [Xen-devel] [RFC PATCH] xen-netback: fix error handling on
 netback_probe()
Date: Thu, 15 Sep 2016 16:05:17 +0200
Message-ID: <c8e11688-cb11-69f6-2c79-daa0f2b3e8b4@neclab.eu>
References: <1473768687-27384-1-git-send-email-filipe.manco@neclab.eu>
 <20160914101023.GY15958@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
        Xen-devel <xen-devel@lists.xenproject.org>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.neclab.eu ([195.37.70.40]:54095 "EHLO mailer1.neclab.eu"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753626AbcIOOF1 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Sep 2016 10:05:27 -0400
In-Reply-To: <20160914101023.GY15958@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 14-09-2016 12:10, Wei Liu wrote:
> CC xen-devel as well.
>
> On Tue, Sep 13, 2016 at 02:11:27PM +0200, Filipe Manco wrote:
>> In case of error during netback_probe() (e.g. an entry missing on the
>> xenstore) netback_remove() is called on the new device, which will set
>> the device backend state to XenbusStateClosed by calling
>> set_backend_state(). However, the backend state wasn't initialized by
>> netback_probe() at this point, which will cause and invalid transaction
>> and set_backend_state() to BUG().
>>
>> Initialize the backend state at the beginning of netback_probe() to
>> XenbusStateInitialising, and create a new valid state transaction on
>> set_backend_state(), from XenbusStateInitialising to XenbusStateClosed.
>>
>> Signed-off-by: Filipe Manco <filipe.manco@neclab.eu>
> There is a state machine right before set_backend_state. You would also
> need to update that.
Good point I'll update the diagram.

After looking at the diagram and for consistency, shouldn't the transition
Initialising -> InitWait be handled using set_backend_state()? Currently it
is done directly in netback_probe() code. If you agree I'll submit a v2 with
these two changes.
> According to the definition of XenbusStateInitialising, this patch looks
> plausible to me.
>
> Wei.
>
Filipe
>> ---
>>   drivers/net/xen-netback/xenbus.c | 10 ++++++++++
>>   1 file changed, 10 insertions(+)
>>
>> diff --git a/drivers/net/xen-netback/xenbus.c b/drivers/net/xen-netback/xenbus.c
>> index 6a31f2610c23..c0e5f6994d01 100644
>> --- a/drivers/net/xen-netback/xenbus.c
>> +++ b/drivers/net/xen-netback/xenbus.c
>> @@ -270,6 +270,7 @@ static int netback_probe(struct xenbus_device *dev,
>>   
>>   	be->dev = dev;
>>   	dev_set_drvdata(&dev->dev, be);
>> +	be->state = XenbusStateInitialising;
>>   
>>   	sg = 1;
>>   
>> @@ -515,6 +516,15 @@ static void set_backend_state(struct backend_info *be,
>>   {
>>   	while (be->state != state) {
>>   		switch (be->state) {
>> +		case XenbusStateInitialising:
>> +			switch (state) {
>> +			case XenbusStateClosed:
>> +				backend_switch_state(be, XenbusStateClosed);
>> +				break;
>> +			default:
>> +				BUG();
>> +			}
>> +			break;
>>   		case XenbusStateClosed:
>>   			switch (state) {
>>   			case XenbusStateInitWait:
>> -- 
>> 2.7.4
>>
> _______________________________________________
> Xen-devel mailing list
> Xen-devel@lists.xen.org
> https://lists.xen.org/xen-devel
