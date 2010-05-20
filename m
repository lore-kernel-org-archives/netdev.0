From: Stefano Salsano <stefano.salsano@uniroma2.it>
Subject: Re: [RFC] netem: correlated loss generation (v3)
Date: Thu, 20 May 2010 02:22:07 +0200
Message-ID: <4BF480AF.4090308@uniroma2.it>
References: <4BD84428.30904@uniroma2.it> <20100517205621.036a06e0@nehalam> <20100519214239.GD5146@nuttenaction> <4BF46B90.1000806@uniroma2.it> <20100519230433.GE5146@nuttenaction>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>,
	Fabio Ludovici <fabio.ludovici@yahoo.it>,
	netdev@vger.kernel.org, netem@lists.linuxfoundation.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.uniroma2.it ([160.80.6.16]:55668 "EHLO smtp.uniroma2.it"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752467Ab0ETAW7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 May 2010 20:22:59 -0400
In-Reply-To: <20100519230433.GE5146@nuttenaction>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hagen Paul Pfeifer wrote:
> * Stefano Salsano | 2010-05-20 00:52:00 [+0200]:
> 
>> So my opinion is that the need to emulate "correlated" loss patterns
>> is not academic, but it is a real need from industry... of course we
>> can debate if it is a "niche" requirement or not
> 
> netem is not in the processing hot path, so there is no issue to add an
> additional component. If there are some[TM] users and it is usable, I am
> fine with this patch!
> 
>> tc qdisc change dev wlan0 root netem loss 2 10
>>
>> because this produces broken results...
> 
> How to model this specific network characteristic (2% loss, correlation 10%)
> with your modifications? Can you give us an example?
> 

The definition of "correlation" for the correlated loss was 
intrinsically broken.

We can now use two models to introduce correlated loss events.

One is called GI (General and Intuitive), where the "burst lenght" of 
consecutive loss events is used to measure correlation, so the second 
(optional) parameter is not the "correlation" but the burst lenght:

tc qdisc add dev wlan0 root netem loss_GI ploss burst_length

for example if ploss = 2% then the burst lenght for uncorrelated loss 
will be 1/(1-ploss) = 1 / 0.98 ~= 1.02

this means that you will have almost always isolated loss events if 
burst_lengh is 1.02

everything greater than 1.02 for burst_lenght will add a correlation in 
the loss patterns, for example:

tc qdisc add dev wlan0 root netem loss_GI 2 3

will mean that the loss events will be grouped in bursts of average 
lenght 3 (to keep the 2% loss this will result in less frequent loss 
bursts, but with more consecutive losses per bursts)

The second model is called Gilbert-Elliot model, you have to input two 
parameters p and r:

tc qdisc add dev eth0 root netem loss_gilb_ell p r

p and r are related to ploss and burst_length in the following way:
ploss = p/(p+r)
burst_length = 1/r

Cheers,
Stefano

PS Thank you for your question! It was important to clarify with such an 
example the new approach. We will soon add this discussion to the 
documentation available at 
http://netgroup.uniroma2.it/twiki/bin/view.cgi/Main/NetemCLG


> Cheers, Hagen
> 


-- 
*******************************************************************
Stefano Salsano
Dipartimento Ingegneria Elettronica
Universita' di Roma "Tor Vergata"
Via del Politecnico, 1 - 00133 Roma - ITALY

http://netgroup.uniroma2.it/Stefano_Salsano/

E-mail  : stefano.salsano@uniroma2.it
Cell.   : +39 320 4307310
Office  : (Tel.) +39 06 72597770  (Fax.) +39 06 72597435
*******************************************************************
