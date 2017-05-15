From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] rt2x00: improve calling conventions for register
 accessors
Date: Mon, 15 May 2017 10:39:51 -0400 (EDT)
Message-ID: <20170515.103951.2305484593464882104.davem@davemloft.net>
References: <20170515134711.2770374-1-arnd@arndb.de>
        <20170515142520.GA13996@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, helmut.schaa@googlemail.com, kvalo@codeaurora.org,
        daniel@makrotopia.org, dev@kresin.me, johannes.berg@intel.com,
        pozega.tomislav@gmail.com, vasilugin@yandex.ru, roman@advem.lv,
        linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: sgruszka@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35532 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934356AbdEOOjy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 15 May 2017 10:39:54 -0400
In-Reply-To: <20170515142520.GA13996@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stanislaw Gruszka <sgruszka@redhat.com>
Date: Mon, 15 May 2017 16:28:01 +0200

> On Mon, May 15, 2017 at 03:46:55PM +0200, Arnd Bergmann wrote:
>> With CONFIG_KASAN enabled and gcc-7, we get a warning about rather high
>> stack usage (with a private patch set I have to turn on this warning,
>> which I intend to get into the next kernel release):
>> 
>> wireless/ralink/rt2x00/rt2800lib.c: In function 'rt2800_bw_filter_calibration':
>> wireless/ralink/rt2x00/rt2800lib.c:7990:1: error: the frame size of 2144 bytes is larger than 1536 bytes [-Werror=frame-larger-than=]
>> 
>> The problem is that KASAN inserts a redzone around each local variable that
>> gets passed by reference, and the newly added function has a lot of them.
>> We can easily avoid that here by changing the calling convention to have
>> the output as the return value of the function. This should also results in
>> smaller object code, saving around 4KB in .text with KASAN, or 2KB without
>> KASAN.
>> 
>> Fixes: 41977e86c984 ("rt2x00: add support for MT7620")
>> Signed-off-by: Arnd Bergmann <arnd@arndb.de>
>> ---
>>  drivers/net/wireless/ralink/rt2x00/rt2800lib.c | 319 +++++++++++++------------
>>  1 file changed, 164 insertions(+), 155 deletions(-)
> 
> We have read(, &val) calling convention since forever in rt2x00 and that
> was never a problem. I dislike to change that now to make some tools
> happy, I think problem should be fixed in the tools instead.

Passing return values by reference is and always has been a really
poor way to achieve what these functions are doing.

And frankly, whilst the tool could see what's going on here better, we
should be making code easier rather than more difficult to audit.

I am therefore very much in favor of Arnd's change.

This isn't even a situation where there are multiple return values,
such as needing to signal an error and return an unsigned value at the
same time.

These functions return _one_ value, and therefore they should be
returned as a true return value.

Thanks.
