From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH net-next] em_canid: Ematch rule to match CAN frames according
 to their CAN IDs
Date: Thu, 28 Jun 2012 18:35:52 +0200
Message-ID: <4FEC87E8.1030405@hartkopp.net>
References: <1340022131-7827-1-git-send-email-lisovy@gmail.com>  <4FEA169C.1070709@hartkopp.net> <1340890522.6032.22.camel@lolumad>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linux-can@vger.kernel.org, lartc@vger.kernel.org,
	pisa@cmp.felk.cvut.cz, sojkam1@fel.cvut.cz
To: Rostislav Lisovy <lisovy@gmail.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1340890522.6032.22.camel@lolumad>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Rostislav,

On 28.06.2012 15:35, Rostislav Lisovy wrote:

> Hello Oliver;
> 
> On Tue, 2012-06-26 at 22:07 +0200, Oliver Hartkopp wrote: 
>> I found some time for a review. See details inline ...
>>
> I agree with quite everything except for following...
> 
> 
>>> +				match = true;
>>
>>
>> match = 1;
>>
> egrep -r "= true;" ./linux-source | wc -l
> returns 6770 -- why don't you like "= true"?
> 


Just because match is an integer and no boolean.
To me integers contain values - or you assign it to constants which are
usually defined in CAPITAL letters like TRUE and FALSE :-)

You define an int instead of a boolean and use true and false.
It's just a inconvenient mix to me.
Don't know.

> 
>>> +				break;
>>> +			}
>>> +		}
>>> +	} else { /* SFF */
>>> +		can_id &= CAN_SFF_MASK;
>>> +		match = test_bit(can_id, cm->match_sff);
>>> +	}
>>> +
>>
>>
>> return match;
>>
> match() function must return 1 or 0, however (from my experience)
> test_bit() returns 0 and non-0 (strictly speaking, in my case, 0 and
> -1).


As you need to return "1" or "0" with your function you should stick on 'int'
and real values IMO.

What about 

	match = (test_bit(can_id, cm->match_sff))?1:0;

and working with "1" and "0" all the time instead of the final correction to
the return values at the end of the function?

Like this (based on the latest version in your git):

diff --git a/net/sched/em_canid.c b/net/sched/em_canid.c
index f0c7c75..9e4b705 100644
--- a/net/sched/em_canid.c
+++ b/net/sched/em_canid.c
@@ -98,7 +98,7 @@ static int em_canid_match(struct sk_buff *skb, struct tcf_ematch *m,
 {
        struct canid_match *cm = em_canid_priv(m);
        canid_t can_id;
-       int match = false;
+       int match = 0;
        int i;
        const struct can_filter *lp;
 
@@ -108,19 +108,16 @@ static int em_canid_match(struct sk_buff *skb, struct tcf_ematch *m,
                for (i = 0, lp = cm->rules_raw;
                     i < cm->eff_rules_count; i++, lp++) {
                        if (!(((lp->can_id ^ can_id) & lp->can_mask))) {
-                               match = true;
+                               match = 1;
                                break;
                        }
                }
        } else { /* SFF */
                can_id &= CAN_SFF_MASK;
-               match = test_bit(can_id, cm->match_sff);
+               match = (test_bit(can_id, cm->match_sff))?1:0;
        }
 
-       if (match)
-               return 1;
-
-       return 0;
+       return match;
 }
 
 static int em_canid_change(struct tcf_proto *tp, void *data, int len,


It's nitpicking - but the if statement to tweak the return value from
test_bit() is only performed in the test_bit() case.

> 
> 
>>> +				&conf[i],
>>> +				sizeof(struct can_filter));
>>> +
>>> +			cm->eff_rules_count++;
>>> +		} else {
>>> +			continue;
>>> +		}
>>
>>
>> omit { } around continue
>>
> http://lxr.linux.no/#linux+v3.4.4/Documentation/CodingStyle#L169
> 


ok.

> 
>>> +	}
>>> +
>>> +	/* Process SFF frame rules */
>>> +	for (i = 0; i < cm->rules_count; i++) {
>>> +		if ((conf[i].can_id & CAN_EFF_FLAG) &&
>>> +		    (conf[i].can_mask & CAN_EFF_FLAG)) {
>>
>>
>> What if CAN_EFF_FLAG is set in can_id but not in can_mask ?
>>
> There were small misunderstanding from my side -- this will be rewritten
> in the way that EFF_FLAG in mask will determine if we care about the
> value of EFF_FLAG in an identifier -- i.e. when EFF_FLAG is set in the
> mask, the rule will be added as SFF or EFF only depending on EFF_FLAG
> value in the identifier. If EFF_FLAG is 0 in the mask, the rule will be
> added as both SFF and EFF.
> 


Great.

Tnx,
Oliver
