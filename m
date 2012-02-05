From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH 1/1] wireless: move ifs' in _rtl92c_store_pwrIndex_diffrate_offset
 into elseif statements
Date: Sun, 05 Feb 2012 10:05:44 -0600
Message-ID: <4F2EA8D8.4080907@lwfinger.net>
References: <1327906245-8200-1-git-send-email-devendra.aaru@gmail.com> <4F2E39F6.70803@computer.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Devendra.Naga" <devendra.aaru@gmail.com>,
	chaoming_li@realsil.com.cn, linville@tuxdriver.com,
	paul.gortmaker@windriver.com, joe@perches.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jan Ceuleers <jan.ceuleers@computer.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:55331 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751149Ab2BEQFs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Feb 2012 11:05:48 -0500
In-Reply-To: <4F2E39F6.70803@computer.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/05/2012 02:12 AM, Jan Ceuleers wrote:
> On 01/30/2012 07:50 AM, Devendra.Naga wrote:
>> From: "Devendra.Naga"<devendra.aaru@gmail.com>
>>
>> The regaddr is compared against different rates in each case and the
>> powerlevels are set
>> accordingly. as this can match for the first if and we still check for other
>> powerlevels too,
>> use else if ratherthan using if statements
>> Signed-off-by: Devendra.Naga<devendra.aaru@gmail.com>
> If this is correct, and I'm not saying it is or isn't, would it not be clearer
> to turn this whole section into a switch statement? The cases that requiring
> fiddling with the bitmask would need to be dealt with in the default: case.

Yes, it is correct. It might be clearer if it were written as a switch 
statement, but that would be a lot more intrusive. Besides, have you ever looked 
at the way gcc compiles a switch? I have done some reverse engineering, and at 
least some implementations generate code that looks like if .. else if .. .. 
else. I have not looked at the generated code, but I'm quite certain that the 
optimizer in gcc is good enough to know that once it gets a match between 
regaddr and one of the RTXAGC constants, there is no need to test the rest, and 
that the change to "else if" is mostly cosmetic, and will not greatly affect the 
execution.

> Why was it written as a series of if statements to begin with: can (or could)
> any of these if statements change the value of regaddr such that later ifs
> evaluate differently? From reading only the patch the answer seems to be "no",
> so that looks good.

I cannot answer the question of why it was written this way - you would have to 
ask the original authors. As to the possibility of the code changing regaddr, 
you either need to look more carefully at the code, or you need to restudy how C 
works.

> Or what about turning this into a data-driven section? It looks like values of
> regaddr are being translated into offsets into
> rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt]. Can this be done with a lookup table?

I would state it a little differently - the values of regaddr are used to 
determine where in the double-indexed array rtlphy->MCS_TXPWR[][] that the 
quantity "data" should be placed. There are always multiple ways to do anything. 
For the kernel, a major rule is to make minimal changes that are easy to verify. 
The patch in question meets that condition. If this code were in the hot path, 
it might be worth the effort required to do a complete rewrite with the 
associated testing, but in my mind, that effort would be wasted. Something that 
would be easy to do, easy to verify, and would reduce the size of the generated 
code would be

int index;

if (regaddr == RTXAGC_A_RATE18_06) {
	index = 0;
else if (if (regaddr == RTXAGC_A_RATE54_24) {
	index = 1;
.....
}
rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][index] = data;
RT_TRACE(rtlpriv, COMP_INIT, DBG_TRACE,
          "MCSTxPowerLevelOriginalOffset[%d][%d] = 0x%x\n",
          rtlphy->pwrgroup_cnt, index,
          rtlphy->MCS_TXPWR[rtlphy->pwrgroup_cnt][index]);
...

Larry
