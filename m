From: "David S. Miller" <davem@davemloft.net>
Subject: Re: design for TSO performance fix
Date: Tue, 1 Feb 2005 15:04:30 -0800
Message-ID: <20050201150430.309978b6.davem@davemloft.net>
References: <20050127163146.33b01e95.davem@davemloft.net>
	<20050128015751.GT31837@postel.suug.ch>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="Multipart=_Tue__1_Feb_2005_15_04_30_-0800_ObOyiQ/wBWaZ/9U9"
Cc: netdev@oss.sgi.com
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20050128015751.GT31837@postel.suug.ch>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.

--Multipart=_Tue__1_Feb_2005_15_04_30_-0800_ObOyiQ/wBWaZ/9U9
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit

On Fri, 28 Jan 2005 02:57:51 +0100
Thomas Graf <tgraf@suug.ch> wrote:

> > static inline int tcp_skb_data_all_paged(struct sk_buff *skb)
> > {
> > 	return (skb->len == skb->data_len);
> > }
> 
> You could also define this as (skb_headlen(skb) == 0)

Good point, I'll do it that way.

> I assume the case when reroute changes oif to a device no
> longer capable of SG+CSUM stays the same and the skb remains
> paged until dev_queue_xmit?

That's correct.  The only difference is that the TSO building
path of send queue transmit will not be executed.

I'm slowly piecing together an implementation.  The most non-
trivial aspect is the frame pushing logic.  While building the
queue from userspace, we wish to defer until either 1) the user
will not supply more data or 2) there is enough in the send
queue for an optimally sized TSO frame to be built.

For the curious, there is attached my current state of implementation.
It's very raw, but it starts to give the basic ideas.  The first
attachment are the design notes I've been jotting down casually
while thinking about this, and the second is the rough beginnings
of a patch.

The patch implements the tp->tso_goal calculations, and the TSO
segmentizer, but nothing else.  The missing pieces are:

1) the push-pending-frames logic, it requires the most thought
1.5) the code in tcp_write_xmit() that tries to call the TSO
     segmenter with groups of SKBs to send
2) killing of tp->mss_cache_std, use tp->mss_cache for everything
3) kill all the code disabling TSO during packet drops
4) kill all the pcount stuff

I'll continue trying to make more progress with this thing.

--Multipart=_Tue__1_Feb_2005_15_04_30_-0800_ObOyiQ/wBWaZ/9U9
Content-Type: text/plain;
 name="tcp_tso.txt"
Content-Disposition: attachment;
 filename="tcp_tso.txt"
Content-Transfer-Encoding: 7bit


Maintain some "TSO potential" state during segmentation at
sendmsg()/sendpage() time.  Use this at push-pending-frames
time to defer tcp_write_xmit() calls and control it's behavior.

Add tcp_flush_queue() which doesn't try to optimize TSO,
it is invoked when getting packets out is more important
than producing larger TSO chunks.  These two cases are:

1) At end of sendmsg()/sendpage() call without MSG_MORE,
   indicating that we have no way to know for sure if
   the user will queue up more TCP data to send.

2) When sleeping within sendmsg()/sendpage() waiting for
   memory.  Pushing out packets and receiving the ACKs
   may very well be the event that will free up send
   queue space for us.

(Must consider interactions with Nagle and Minshall rules)

Consider tcp_opt state which keeps a "TSO goal", it
must be in sync with tcp_opt MSS state.  Initially
define "TSO goal" using tcp_tso_win_divisor and the
current congestion window.  Formally this is:

	max(1U, CWND / TCP_TSO_WIN_DIVISOR)

We could either maintain this lazily, costing us a divide
each time it is recalculated.  Or, we can update it
incrementally each time snd_cwnd is updated.

To save some state testing during output decisions,
define "TSO goal" as one for non-TSO flows.

Possible send test logic:

	if (no new data possibly coming from user)
		send_now();
	if (sending due to ACK queue advancement)
		send_now();
	send_tso_goal_sized_chunks();

--Multipart=_Tue__1_Feb_2005_15_04_30_-0800_ObOyiQ/wBWaZ/9U9
Content-Type: application/octet-stream;
 name="diff"
Content-Disposition: attachment;
 filename="diff"
Content-Transfer-Encoding: base64

PT09PT0gaW5jbHVkZS9saW51eC90Y3AuaCAxLjM0IHZzIGVkaXRlZCA9PT09PQotLS0gMS4zNC9p
bmNsdWRlL2xpbnV4L3RjcC5oCTIwMDUtMDEtMTcgMTQ6MDk6MzMgLTA4OjAwCisrKyBlZGl0ZWQv
aW5jbHVkZS9saW51eC90Y3AuaAkyMDA1LTAxLTMxIDE2OjAzOjMyIC0wODowMApAQCAtMjYyLDYg
KzI2Miw3IEBACiAJX191MzIJcG10dV9jb29raWU7CS8qIExhc3QgcG10dSBzZWVuIGJ5IHNvY2tl
dAkJKi8KIAlfX3UzMgltc3NfY2FjaGU7CS8qIENhY2hlZCBlZmZlY3RpdmUgbXNzLCBub3QgaW5j
bHVkaW5nIFNBQ0tTICovCiAJX191MTYJbXNzX2NhY2hlX3N0ZDsJLyogTGlrZSBtc3NfY2FjaGUs
IGJ1dCB3aXRob3V0IFRTTyAqLworCV9fdTE2CXRzb19nb2FsOwkvKiBUU08gcGFja2V0IGNvdW50
IGdvYWwsIDEgdy9ub24tVFNPIHBhdGhzICovCiAJX191MTYJbXNzX2NsYW1wOwkvKiBNYXhpbWFs
IG1zcywgbmVnb3RpYXRlZCBhdCBjb25uZWN0aW9uIHNldHVwICovCiAJX191MTYJZXh0X2hlYWRl
cl9sZW47CS8qIE5ldHdvcmsgcHJvdG9jb2wgb3ZlcmhlYWQgKElQL0lQdjYgb3B0aW9ucykgKi8K
IAlfX3UxNglleHQyX2hlYWRlcl9sZW47LyogT3B0aW9ucyBkZXBlbmRpbmcgb24gcm91dGUgKi8K
PT09PT0gbmV0L2lwdjQvdGNwX291dHB1dC5jIDEuNzcgdnMgZWRpdGVkID09PT09Ci0tLSAxLjc3
L25ldC9pcHY0L3RjcF9vdXRwdXQuYwkyMDA1LTAxLTE4IDEyOjIzOjM2IC0wODowMAorKysgZWRp
dGVkL25ldC9pcHY0L3RjcF9vdXRwdXQuYwkyMDA1LTAyLTAxIDE0OjMyOjQ2IC0wODowMApAQCAt
NzA3LDE1ICs3MDcsMTAzIEBACiAJCWlmIChmYWN0b3IgPiBsaW1pdCkKIAkJCWZhY3RvciA9IGxp
bWl0OwogCi0JCXRwLT5tc3NfY2FjaGUgPSBtc3Nfbm93ICogZmFjdG9yOworCQkvKiBJZiB0aGlz
IGV2ZXIgdHJpZ2dlcnMsIGNoYW5nZSB0cC0+dHNvX2dvYWwgdG8KKwkJICogYSBsYXJnZXIgdHlw
ZSBhbmQgdXBkYXRlIHRoaXMgYnVnIGNoZWNrLgorCQkgKi8KKwkJQlVHX09OKGZhY3RvciA+IDY1
NTM1KTsKIAotCQltc3Nfbm93ID0gdHAtPm1zc19jYWNoZTsKLQl9CisJCXRwLT50c29fZ29hbCA9
IGZhY3RvcjsKKwl9IGVsc2UKKwkJdHAtPnRzb19nb2FsID0gMTsKIAogCWlmICh0cC0+ZWZmX3Nh
Y2tzKQogCQltc3Nfbm93IC09IChUQ1BPTEVOX1NBQ0tfQkFTRV9BTElHTkVEICsKIAkJCSAgICAo
dHAtPmVmZl9zYWNrcyAqIFRDUE9MRU5fU0FDS19QRVJCTE9DSykpOwogCXJldHVybiBtc3Nfbm93
OworfQorCitzdGF0aWMgaW5saW5lIGludCB0Y3Bfc2tiX2RhdGFfYWxsX3BhZ2VkKHN0cnVjdCBz
a19idWZmICpza2IpCit7CisJcmV0dXJuIHNrYl9oZWFkbGVuKHNrYikgPT0gMDsKK30KKworLyog
SWYgcG9zc2libGUsIGFwcGVuZCBwYWdlZCBkYXRhIG9mIFNSQ19TS0Igb250byB0aGUKKyAqIHRh
aWwgb2YgRFNUX1NLQi4KKyAqLworc3RhdGljIGludCBza2JfYXBwZW5kX3BhZ2VzKHN0cnVjdCBz
a19idWZmICpkc3Rfc2tiLCBzdHJ1Y3Qgc2tfYnVmZiAqc3JjX3NrYikKK3sKKwlpbnQgaTsKKwor
CWlmICghdGNwX3NrYl9kYXRhX2FsbF9wYWdlZChzcmNfc2tiKSkKKwkJcmV0dXJuIC1FSU5WQUw7
CisKKwlmb3IgKGkgPSAwOyBpIDwgc2tiX3NoaW5mbyhzcmNfc2tiKS0+bnJfZnJhZ3M7IGkrKykg
eworCQlza2JfZnJhZ190ICpzcmNfZnJhZyA9ICZza2Jfc2hpbmZvKHNyY19za2IpLT5mcmFnc1tp
XTsKKwkJc2tiX2ZyYWdfdCAqZHN0X2ZyYWc7CisJCWludCBkc3RfZnJhZ19pZHg7CisKKwkJZHN0
X2ZyYWdfaWR4ID0gc2tiX3NoaW5mbyhkc3Rfc2tiKS0+bnJfZnJhZ3M7CisKKwkJaWYgKHNrYl9j
YW5fY29hbGVzY2UoZHN0X3NrYiwgZHN0X2ZyYWdfaWR4LAorCQkJCSAgICAgc3JjX2ZyYWctPnBh
Z2UsIHNyY19mcmFnLT5wYWdlX29mZnNldCkpIHsKKwkJCWRzdF9mcmFnID0gJnNrYl9zaGluZm8o
ZHN0X3NrYiktPmZyYWdzW2RzdF9mcmFnX2lkeC0xXTsKKwkJCWRzdF9mcmFnLT5zaXplICs9IHNy
Y19mcmFnLT5zaXplOworCQl9IGVsc2UgeworCQkJaWYgKGRzdF9mcmFnX2lkeCA+PSBNQVhfU0tC
X0ZSQUdTKQorCQkJCXJldHVybiAtRU1TR1NJWkU7CisKKwkJCWRzdF9mcmFnID0gJnNrYl9zaGlu
Zm8oZHN0X3NrYiktPmZyYWdzW2RzdF9mcmFnX2lkeF07CisJCQlza2Jfc2hpbmZvKGRzdF9za2Ip
LT5ucl9mcmFncyA9IGRzdF9mcmFnX2lkeCArIDE7CisKKwkJCWRzdF9mcmFnLT5wYWdlID0gc3Jj
X2ZyYWctPnBhZ2U7CisJCQlnZXRfcGFnZShzcmNfZnJhZy0+cGFnZSk7CisKKwkJCWRzdF9mcmFn
LT5wYWdlX29mZnNldCA9IHNyY19mcmFnLT5wYWdlX29mZnNldDsKKwkJCWRzdF9mcmFnLT5zaXpl
ID0gc3JjX2ZyYWctPnNpemU7CisJCX0KKwkJZHN0X3NrYi0+ZGF0YV9sZW4gKz0gc3JjX2ZyYWct
PnNpemU7CisJfQorCisJcmV0dXJuIDA7Cit9CisKK3N0YXRpYyBzdHJ1Y3Qgc2tfYnVmZiAqdGNw
X3Rzb19idWlsZChzdHJ1Y3Qgc2tfYnVmZiAqaGVhZCwgaW50IG1zcywgaW50IG51bSkKK3sKKwlz
dHJ1Y3Qgc2tfYnVmZiAqc2tiOworCXN0cnVjdCBzb2NrICpzazsKKwlpbnQgZXJyOworCisJc2sg
PSBoZWFkLT5zazsKKwlza2IgPSBhbGxvY19za2Ioc2stPnNrX3Byb3QtPm1heF9oZWFkZXIsIEdG
UF9BVE9NSUMpOworCWVyciA9IC1FTk9NRU07CisJaWYgKCFza2IpCisJCWdvdG8gZmFpbDsKKwor
CWVyciA9IDA7CisJc2tiX3NoaW5mbyhza2IpLT50c29fc2l6ZSA9IG1zczsKKwlza2Jfc2hpbmZv
KHNrYiktPnRzb19zZWdzID0gbnVtOworCXdoaWxlIChudW0tLSkgeworCQllcnIgPSBza2JfYXBw
ZW5kX3BhZ2VzKHNrYiwgaGVhZCk7CisJCWlmIChlcnIpCisJCQlnb3RvIGZhaWw7CisKKwkJaGVh
ZCA9IGhlYWQtPm5leHQ7CisJfQorCXJldHVybiBza2I7CisKK2ZhaWw6CisJaWYgKHNrYikgewor
CQlpbnQgaTsKKworCQlmb3IgKGkgPSAwOyBpIDwgc2tiX3NoaW5mbyhza2IpLT5ucl9mcmFnczsg
aSsrKSB7CisJCQlza2JfZnJhZ190ICpmcmFnID0gJnNrYl9zaGluZm8oc2tiKS0+ZnJhZ3NbaV07
CisKKwkJCXB1dF9wYWdlKGZyYWctPnBhZ2UpOworCQl9CisKKwkJa2ZyZWVfc2tiKHNrYik7CisJ
fQorCXJldHVybiBOVUxMOwogfQogCiAvKiBUaGlzIHJvdXRpbmUgd3JpdGVzIHBhY2tldHMgdG8g
dGhlIG5ldHdvcmsuICBJdCBhZHZhbmNlcyB0aGUK

--Multipart=_Tue__1_Feb_2005_15_04_30_-0800_ObOyiQ/wBWaZ/9U9--
