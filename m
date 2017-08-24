From: Aviad Krawczyk <aviad.krawczyk@huawei.com>
Subject: Re: [PATCH][next] net: hinic: fix comparison of a uint16_t type with
 -1
Date: Thu, 24 Aug 2017 12:38:05 +0300
Message-ID: <ded74048-2d3f-115d-bc47-3be019859e33@huawei.com>
References: <20170823153936.22857-1-colin.king@canonical.com>
 <58f312cc-5f24-83b6-d12d-c66e4fd4dad2@huawei.com>
 <d37c85d8-3954-e7b7-e569-f18c2b062966@canonical.com>
 <20170824092951.ozllwwklfld44u5u@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <kernel-janitors@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>
To: Dan Carpenter <dan.carpenter@oracle.com>,
        Colin Ian King <colin.king@canonical.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170824092951.ozllwwklfld44u5u@mwanda>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 8/24/2017 12:29 PM, Dan Carpenter wrote:
> On Thu, Aug 24, 2017 at 09:54:03AM +0100, Colin Ian King wrote:
>> On 24/08/17 09:48, Aviad Krawczyk wrote:
>>> On 8/23/2017 6:39 PM, Colin King wrote:
>>>> From: Colin Ian King <colin.king@canonical.com>
>>>>
>>>> The comparison of hw_ioctxt.rx_buf_sz_idx == -1 is always false because
>>>> rx_buf_sz_idx is a uint16_t. Fix this by explicitly casting -1 to uint16_t.
>>>>
>>>> Detected by CoverityScan, CID#1454559 ("Operands don't affect result")
>>>>
>>>> Signed-off-by: Colin Ian King <colin.king@canonical.com>
>>>> ---
>>>>  drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
>>>> index 09dec6de8dd5..71e26070fb7f 100644
>>>> --- a/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
>>>> +++ b/drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
>>>> @@ -352,7 +352,7 @@ static int set_hw_ioctxt(struct hinic_hwdev *hwdev, unsigned int rq_depth,
>>>>  		}
>>>>  	}
>>>>  
>>>> -	if (hw_ioctxt.rx_buf_sz_idx == -1)
>>>> +	if (hw_ioctxt.rx_buf_sz_idx == (uint16_t)-1)
>>>>  		return -EINVAL;
>>>>  
>>>>  	hw_ioctxt.sq_depth  = ilog2(sq_depth);
>>>>
>>>
>>> Many thanks, Colin.
>>> I prefer to avoid casting when possible, what do you think about replacing the condition by:
>>>
>>> if (rx_buf_sz_table[i].sz != HINIC_RX_BUF_SZ)
>>> 	return -EINVAL;
>>>
>>
>> Does that work as expected when rx_buf_sz_table[i].sz == -1?
> 
> No it doesn't.  Please, don't ask rhetorical questions.  I have a
> toddler and I constantly ask him toddler level questions and it drives
> me nuts that all the adults in the room will answer me...  "Yes, I
> already know that's a cow.  I was quizing my son.  But thank you!"
> Meanwhile I can't resist answering questions myself...
> 
> The code looks like this:
> 
> drivers/net/ethernet/huawei/hinic/hinic_hw_dev.c
>    345          hw_ioctxt.rq_depth  = ilog2(rq_depth);
>    346  
>    347          for (i = 0; ; i++) {
>    348                  if ((rx_buf_sz_table[i].sz == HINIC_RX_BUF_SZ) ||
>    349                      (rx_buf_sz_table[i].sz == -1)) {
>    350                          hw_ioctxt.rx_buf_sz_idx = rx_buf_sz_table[i].idx;
>    351                          break;
>    352                  }
>    353          }
>    354  
>    355          if (hw_ioctxt.rx_buf_sz_idx == -1)
>    356                  return -EINVAL;
>    357  
> 
> The loop doesn't make sense.  We are looping through rx_buf_sz_table[]
> until we hit 2048 or -1.  But 2048 comes first so we always get there
> and break.
> 
> We may as well replace all that code with:
> 
> 		hw_ioctxt.rx_buf_sz_idx = 11;
> 
> Something is very wrong.
> 
> regards,
> dan carpenter
> 
> 
> .
> 

Hi Dan,

What if HINIC_RX_BUF_SZ is changed to another value?
The test checks if the HINIC_RX_BUF_SZ is in the table, if not return -EINVAL.
Therefore I think the check of rx_buf_sz_table[i].sz != HINIC_RX_BUF_SZ is better.

Aviad
