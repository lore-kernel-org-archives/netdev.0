From: John Crispin <john@phrozen.org>
Subject: Re: [PATCH] net: dsa: properly disconnect the slave PHYs
Date: Tue, 18 Oct 2016 14:54:30 +0200
Message-ID: <a310cfb9-8000-3906-242e-501900d5c8a0@phrozen.org>
References: <1476792760-60356-1-git-send-email-john@phrozen.org>
 <20161018122909.GR26778@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([46.4.11.11]:37884 "EHLO nbd.name"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1759777AbcJRMyf (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 18 Oct 2016 08:54:35 -0400
In-Reply-To: <20161018122909.GR26778@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 18/10/2016 14:29, Andrew Lunn wrote:
> On Tue, Oct 18, 2016 at 02:12:40PM +0200, John Crispin wrote:
>> The shutdown code only stopped the PHYs but does not diconnect them
>> properly. This could lead to null pointer deref related kernel oopses
>> during reboot. Fix this by calling phy_disconnect() after the PHYs are
>> stopped.
> 
> Humm, i don't follow this.
> 
> The phy is disconnected in dsa_slave_destroy(). Why is that not
> sufficient?
> 
> Also, after calling dsa_slave_close(), dsa_slave_open() can be
> called. But with your change, the phy has gone, so we are going to
> have trouble.
> 
> 	Andrew
> 

Hi Andrew

i am testing on v4.4 which did not have a phy_disconnect() call. this
seems to have been fixed by cda5c15b so please ignore this patch

	John

>>
>> Signed-off-by: John Crispin <john@phrozen.org>
>> ---
>>  net/dsa/slave.c |    4 +++-
>>  1 file changed, 3 insertions(+), 1 deletion(-)
>>
>> diff --git a/net/dsa/slave.c b/net/dsa/slave.c
>> index 68714a5..725d9f7 100644
>> --- a/net/dsa/slave.c
>> +++ b/net/dsa/slave.c
>> @@ -154,8 +154,10 @@ static int dsa_slave_close(struct net_device *dev)
>>  	struct net_device *master = p->parent->dst->master_netdev;
>>  	struct dsa_switch *ds = p->parent;
>>  
>> -	if (p->phy)
>> +	if (p->phy) {
>>  		phy_stop(p->phy);
>> +		phy_disconnect(p->phy);
>> +	}
>>  
>>  	dev_mc_unsync(master, dev);
>>  	dev_uc_unsync(master, dev);
>> -- 
>> 1.7.10.4
>>
