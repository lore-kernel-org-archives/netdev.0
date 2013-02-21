From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: why is it not allowed to add a new socket protocol family as
 an external module?
Date: Thu, 21 Feb 2013 09:47:33 -0600
Message-ID: <51264195.9060800@genband.com>
References: <5125002D.9080008@genband.com>	 <20130220152325.64c57d55@samsung-9> <51256E02.4080509@genband.com> <1361410797.17413.3.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og109.obsmtp.com ([64.18.2.171]:57628 "EHLO
	exprod7og109.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147Ab3BUPrh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Feb 2013 10:47:37 -0500
In-Reply-To: <1361410797.17413.3.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/20/2013 07:39 PM, Eric Dumazet wrote:
> On Wed, 2013-02-20 at 18:44 -0600, Chris Friesen wrote:
>
>> Yes, there are a number of tables sized by NPROTO/AF_MAX/PF_MAX (and the
>> fact that we use all three within the kernel is kind of sad) but there
>> is no technical reason why we couldn't extend those dynamically if
>> desired (with a linked list of additional protocols, perhaps).
>>
>> Hence my question--is the restriction for an ideological reason or
>> simply because nobody thought it was worth the effort?
>>
>
> I guess nobody did the preliminary work.
>
> lockdep might be the tricky part.
>
> net/core/sock.c:197:static const char *const af_family_key_strings[AF_MAX+1] = {
> net/core/sock.c:211:  "sk_lock-AF_NFC"   , "sk_lock-AF_MAX"
> net/core/sock.c:213:static const char *const af_family_slock_key_strings[AF_MAX+1] = {
> net/core/sock.c:227:  "slock-AF_NFC"   , "slock-AF_MAX"
> net/core/sock.c:229:static const char *const af_family_clock_key_strings[AF_MAX+1] = {
> net/core/sock.c:243:  "clock-AF_NFC"   , "clock-AF_MAX"
> net/core/sock.c:250:static struct lock_class_key af_callback_keys[AF_MAX];

Unless I'm missing something that looks straightforward.

When registering dynamically the new protocol would need to specify one 
string, the protocol name.  ("AF_MYPROTOCOL" or something).  The three 
key strings are derived from that.

The three lock_class_key structs (corresponding to 
af_family_keys/af_family_slock_keys/af_callback_keys) can be 
auto-allocated by the network core at dynamic registration time.

sock_lock_init(), sk_clone_lock(), and sock_init_data() would need 
special-casing for protocol number larger than AF_MAX.  The most 
readable would probably be to do the mapping from family to key/string 
in helper functions rather than hard-coding a table offset right in 
these routines.

Yes, there would be a runtime penalty, but it should be minimal.  For 
static protocols it would be a few "sk->sk_family < AF_MAX" checks.  For 
dynamic protocols they might need to walk a linked list, which in all 
probability would be very short.

Chris
