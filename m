From: Vlad Yasevich <vyasevich@gmail.com>
Subject: Re: [PATCH net-next] bridge: Fix incorrect judgment of
	promisc
Date: Thu, 05 Jun 2014 11:06:07 -0400
Message-ID: <5390875F.9040804@gmail.com>
References: <1401965851-6449-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
	<063D6719AE5E284EB5DD2968C1650D6D17257C08@AcuExch.aculab.com>
	<539052C0.2090409@lab.ntt.co.jp>
	<063D6719AE5E284EB5DD2968C1650D6D17257D43@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vyasevic@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"bridge@lists.linux-foundation.org" <bridge@lists.linux-foundation.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Toshiaki Makita' <makita.toshiaki@lab.ntt.co.jp>,
	"David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>
Return-path: <bridge-bounces@lists.linux-foundation.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D17257D43@AcuExch.aculab.com>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

On 06/05/2014 08:55 AM, David Laight wrote:
> From: Toshiaki Makita
>> (2014/06/05 20:03), David Laight wrote:
>>> From: Toshiaki Makita
>>>> br_manage_promisc() incorrectly expects br_auto_port() to return only 0
>>>> or 1, while it actually returns flags, i.e., a subset of BR_AUTO_MASK.
>>>>
>>>> Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
>>>> ---
>>>>  net/bridge/br_if.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
>>>> index a08d2b8..6a07a40 100644
>>>> --- a/net/bridge/br_if.c
>>>> +++ b/net/bridge/br_if.c
>>>> @@ -153,7 +153,7 @@ void br_manage_promisc(struct net_bridge *br)
>>>>  			 * This lets us disable promiscuous mode and write
>>>>  			 * this config to hw.
>>>>  			 */
>>>> -			if (br->auto_cnt <= br_auto_port(p))
>>>> +			if (br->auto_cnt <= !!br_auto_port(p))
>>>>  				br_port_clear_promisc(p);
>>>>  			else
>>>>  				br_port_set_promisc(p);
>>>
>>> Why not the less confusing:
>>> 			if (br->auto_cnt || br_auto_port(p))
>>> and reverse the then/else lines?
>>
>> I'm respecting the original style, but I'm not particular about this style.
>> I'll make less confusing one, thanks :)
>>
>> (Your suggested condition is not exactly the same as current one, even
>> if reversing if/else. v2 will be different than it. Anyway, thanks.)
> 
> A quick truth table:
> 	auto_cnt	auto_port	set/clear
> 		0		0	clear
> 		0		1	clear
               Can't happen

> 		1		0	set
              Can't happen
> 		1		1	clear
> 		2+		0/1	clear
> 
> So you want:
> 	if (br->auto_cnt && !br_auto_port(p))
> 		br_port_set_promisc(p);
> 	else
> 		br_port_clear_promisc(p);

Some versions of the series that added this had
an explicit check for count.  Essentially, the
expanded condition is this:

  if (count == 0)
     clear
  else if (count == 1 && auto_port(p))
     clear
  else
     set

The suggestion was that we could use a boolean (0|1)
to check reduce the above to
  if (count <= auto_port(p))
     clear
  else
     set

Personally, I prefer the extended version since it
is much clearer and is easy to understand.

-vlad

> 
> Does seem like a strange condition.
> 
> 	David
> 
> 	
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
