From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: Fwd: iproute2 wrong burst/cburst calculation?
Date: Tue, 20 Jan 2009 22:57:11 +0200
Message-ID: <200901202257.11773.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Stephen Hemminger <shemminger@vyatta.com>,
	Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:52460 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754806AbZATU5Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Jan 2009 15:57:24 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for duplicate, i forgot to add netdev@, and i added few things more

After reading http://luxik.cdi.cz/~devik/qos/htb/manual/userg.htm

<quote>
When you set burst for parent class smaller than for some child then you 
should expect the parent class to get stuck sometimes (because child will 
drain more than parent can handle). HTB will remember these negative bursts 
up to 1 minute. 
</quote>
I check my shaper, where is burst/cburst calculated automatically. And 
noticed:

class htb 1:10 parent 1:2 rate 250000Kbit ceil 250000Kbit burst 1562b/8 mpu 0b 
overhead 0b cburst 1562b/8 mpu 0b overhead 0b level 6
 Sent 189473054 bytes 264641 pkt (dropped 0, overlimits 0 requeues 0)
 rate 70606Kbit 12304pps backlog 0b 0p requeues 0
 lended: 22353 borrowed: 0 giants: 0
 tokens: -32 ctokens: -32

class htb 1:2 root rate 950000Kbit ceil 950000Kbit burst 1425b/8 mpu 0b 
overhead 0b cburst 1425b/8 mpu 0b overhead 0b level 7
 Sent 330006424 bytes 464968 pkt (dropped 0, overlimits 0 requeues 0)
 rate 122834Kbit 21594pps backlog 0b 0p requeues 0
 lended: 607 borrowed: 0 giants: 0
 tokens: 12 ctokens: 12

class htb 1:20 parent 1:10 leaf 20: prio 0 quantum 200000 rate 200000Kbit ceil 
250000Kbit burst 1575b/8 mpu 0b overhead 0b cburst 1562b/8 mpu 0b overhead 0b 
level 0
 Sent 143772902 bytes 120383 pkt (dropped 0, overlimits 0 requeues 0)
 rate 53968Kbit 5634pps backlog 0b 110p requeues 0
 lended: 118274 borrowed: 1993 giants: 0
 tokens: -54 ctokens: 3

class htb 1:30 parent 1:10 leaf 30: prio 0 quantum 200000 rate 40000Kbit ceil 
250000Kbit burst 1595b/8 mpu 0b overhead 0b cburst 1562b/8 mpu 0b overhead 0b 
level 0
 Sent 46819818 bytes 147786 pkt (dropped 15842, overlimits 0 requeues 0)
 rate 17406Kbit 6862pps backlog 0b 3418p requeues 0
 lended: 124008 borrowed: 20360 giants: 0
 tokens: -75 ctokens: 37

class htb 1:3 parent 1:2 leaf 3: prio 0 quantum 200000 rate 680000Kbit ceil 
950000Kbit burst 1445b/8 mpu 0b overhead 0b cburst 1425b/8 mpu 0b overhead 0b 
level 0
 Sent 140533370 bytes 200327 pkt (dropped 0, overlimits 0 requeues 0)
 rate 52228Kbit 9289pps backlog 0b 0p requeues 0
 lended: 199720 borrowed: 607 giants: 0
 tokens: 17 ctokens: 12

So just look: 1:3 have burst 1445 / 1425, and 1:2, his parent - burst 1425 and 
cburst 1425. It is wrong? I am not so experienced in htb to judge, but i feel 
like iproute2 calculating burst/cburst not right way. 


-------------------------------------------------------

Just few things more, let's review only rate.

opt.rate.rate calculated by get_rate.

if (get_rate(&opt.rate.rate, *argv)) {


int get_rate(unsigned *rate, const char *str)
{
        const struct rate_suffix *s;

        if (p == str)
                return -1;

        if (*p == '\0') {
                *rate = bps / 8.;       /* assume bytes/sec */
                return 0;
        }

        for (s = suffixes; s->name; ++s) {
                if (strcasecmp(s->name, p) == 0) {
                        *rate = (bps * s->scale) / 8.;
                        return 0;
                }
        }




get_rate calculate from my 950Mbit/s and 680Mbps
118750000 and 85000000

opt.rate.rate is speed in byte/s

then burst calculated by

        if (!buffer) buffer = opt.rate.rate / get_hz() + mtu;

Here is most funny things. All variables is integer. I did simulation:

                        
fprintf(stderr,"950Mbps %u %u\n",118750000/get_hz(),get_hz());                      
fprintf(stderr,"680Mbps %u %u\n",85000000/get_hz(),get_hz());

950Mbps 0 1000000000
680Mbps 0 1000000000

and 
                        fprintf(stderr,"950Mbps %u %u\n",118750000/get_hz() + 
mtu,get_hz());
                        fprintf(stderr,"680Mbps %u %u\n",85000000/get_hz() + 
mtu,get_hz());

950Mbps 1600 1000000000
680Mbps 1600 1000000000

So till this point it looks like correct, precision is enough high.

then

opt.buffer = tc_calc_xmittime(opt.rate.rate, buffer);

unsigned tc_calc_xmittime(unsigned rate, unsigned size)
{
        return tc_core_time2tick(TIME_UNITS_PER_SEC*((double)size/rate));
}
13.47 and 18.82
Seems here it is. Then there is 
unsigned tc_core_time2tick(unsigned time)
{
        return time*tick_in_usec;
}
which seems not so important.


I guess it was supposed in this formula, that size must vary, and higher rate 
must have higher size. But because our timer resolution so high, and we add 
also mtu value... things going wrong.
I dont know yet, how to calculate this correctly. Even not sure if it is 
wrong. But HTB author, stated clearly 

"Note: The burst and cburst of a class should always be at least as high as 
that of any of it children. "
