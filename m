From: Josh Hunt <joshhunt00@gmail.com>
Subject: rtt calculation when retransmissions occur during handshake
Date: Mon, 10 Jan 2011 18:52:58 -0800
Message-ID: <AANLkTik9bj0YWWwET8cJWT3VWwxberNQ8zYAeH9fHdbe@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary=0016e65a0d30a3e1fd0499892e22
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:62896 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753955Ab1AKCxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Jan 2011 21:53:00 -0500
Received: by wyb28 with SMTP id 28so20037590wyb.19
        for <netdev@vger.kernel.org>; Mon, 10 Jan 2011 18:52:59 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--0016e65a0d30a3e1fd0499892e22
Content-Type: text/plain; charset=ISO-8859-1

I was wondering if someone could explain the following behavior I'm
seeing on my web server. I've instrumented the kernel to look at the
RTT during TCP handshake. I am seeing the RTTs reported by the kernel
when my initial SYN/ACK is lost to be calculated based on the original
SYN/ACK. Is this behavior correct? Below I have two cases I've seen on
my system. The first shows the client replying to the retransmitted
SYN/ACK but giving an RTT of 900 instead of around 252. The second
shows the client replying to the original SYN/ACK and reports an RTT
of 913. I have tcp_no_metrics_save enabled so there should be no RTT
caching. This is on kernel 2.6.32.20.

(I've attached these trace snippets as it might be tough to read in a
mail client)
* Reported RTT: 900 - looks like RTT should be ~252:
1294443792.878373 IP 1.2.3.4.49174 > 5.6.7.8.80: Flags [S], seq
2495182093, win 65535, options [mss 1460,nop,wscale 3,nop,nop,TS val
759815989 ecr 0,sackOK,eol], length 0
1294443792.878379 IP 5.6.7.8.80 > 1.2.3.4.49174: Flags [S.], seq
4249681570, ack 2495182094, win 5792, options [mss 1460,sackOK,TS val
760394055 ecr 759815989,nop,wscale 5], length 0
1294443793.656624 IP 5.6.7.8.80 > 1.2.3.4.49174: Flags [S.], seq
4249681570, ack 2495182094, win 5792, options [mss 1460,sackOK,TS val
760394834 ecr 759815989,nop,wscale 5], length 0
1294443793.908897 IP 1.2.3.4.49174 > 5.6.7.8.80: Flags [.], ack 1, win
65535, options [nop,nop,TS val 759816000 ecr 760394834], length 0

* Reported RTT: 913 - looks correct since it's replying to the original syn/ack:
1294443634.012920 IP 2.3.4.5.62987 > 5.6.7.8.80: Flags [S], seq
1397298575, win 65535, options [mss 1460,nop,wscale 1,nop,nop,TS val
576497055 ecr 0,sackOK,eol], length 0
1294443634.012931 IP 5.6.7.8.80 > 2.3.4.5.62987: Flags [S.], seq
1761430826, ack 1397298576, win 5792, options [mss 1460,sackOK,TS val
760235190 ecr 576497055,nop,wscale 5], length 0
1294443634.656625 IP 5.6.7.8.80 > 2.3.4.5.62987: Flags [S.], seq
1761430826, ack 1397298576, win 5792, options [mss 1460,sackOK,TS val
760235834 ecr 576497055,nop,wscale 5], length 0
1294443634.925970 IP 2.3.4.5.62987 > 5.6.7.8.80: Flags [.], ack 1, win
33304, options [nop,nop,TS val 576497064 ecr 760235190], length 0

>From what I can tell it appears that once the ACK to establish the
connection is received tcp_ack_update_rtt() is called from
tcp_rcv_state_process(). That will eventually compute the initial srtt
using tcp_time_stamp and the value in rcv_tsecr. Am I missing a
codepath because these are retransmissions?

Thanks for any help you can provide.

Josh

--0016e65a0d30a3e1fd0499892e22
Content-Type: application/octet-stream; name=tcpdump-snippet
Content-Disposition: attachment; filename=tcpdump-snippet
Content-Transfer-Encoding: base64
X-Attachment-Id: f_gis71wmn0

KiBSZXBvcnRlZCBSVFQ6IDkwMCAtIGxvb2tzIGxpa2UgUlRUIHNob3VsZCBiZSB+MjUyOgoxMjk0
NDQzNzkyLjg3ODM3MyBJUCAxLjIuMy40LjQ5MTc0ID4gNS42LjcuOC44MDogRmxhZ3MgW1NdLCBz
ZXEgMjQ5NTE4MjA5Mywgd2luIDY1NTM1LCBvcHRpb25zIFttc3MgMTQ2MCxub3Asd3NjYWxlIDMs
bm9wLG5vcCxUUyB2YWwgNzU5ODE1OTg5IGVjciAwLHNhY2tPSyxlb2xdLCBsZW5ndGggMAoxMjk0
NDQzNzkyLjg3ODM3OSBJUCA1LjYuNy44LjgwID4gMS4yLjMuNC40OTE3NDogRmxhZ3MgW1MuXSwg
c2VxIDQyNDk2ODE1NzAsIGFjayAyNDk1MTgyMDk0LCB3aW4gNTc5Miwgb3B0aW9ucyBbbXNzIDE0
NjAsc2Fja09LLFRTIHZhbCA3NjAzOTQwNTUgZWNyIDc1OTgxNTk4OSxub3Asd3NjYWxlIDVdLCBs
ZW5ndGggMAoxMjk0NDQzNzkzLjY1NjYyNCBJUCA1LjYuNy44LjgwID4gMS4yLjMuNC40OTE3NDog
RmxhZ3MgW1MuXSwgc2VxIDQyNDk2ODE1NzAsIGFjayAyNDk1MTgyMDk0LCB3aW4gNTc5Miwgb3B0
aW9ucyBbbXNzIDE0NjAsc2Fja09LLFRTIHZhbCA3NjAzOTQ4MzQgZWNyIDc1OTgxNTk4OSxub3As
d3NjYWxlIDVdLCBsZW5ndGggMAoxMjk0NDQzNzkzLjkwODg5NyBJUCAxLjIuMy40LjQ5MTc0ID4g
NS42LjcuOC44MDogRmxhZ3MgWy5dLCBhY2sgMSwgd2luIDY1NTM1LCBvcHRpb25zIFtub3Asbm9w
LFRTIHZhbCA3NTk4MTYwMDAgZWNyIDc2MDM5NDgzNF0sIGxlbmd0aCAwCgoqIFJlcG9ydGVkIFJU
VDogOTEzIC0gbG9va3MgY29ycmVjdCBzaW5jZSBpdCdzIHJlcGx5aW5nIHRvIHRoZSBvcmlnaW5h
bCBzeW4vYWNrOgoxMjk0NDQzNjM0LjAxMjkyMCBJUCAyLjMuNC41LjYyOTg3ID4gNS42LjcuOC44
MDogRmxhZ3MgW1NdLCBzZXEgMTM5NzI5ODU3NSwgd2luIDY1NTM1LCBvcHRpb25zIFttc3MgMTQ2
MCxub3Asd3NjYWxlIDEsbm9wLG5vcCxUUyB2YWwgNTc2NDk3MDU1IGVjciAwLHNhY2tPSyxlb2xd
LCBsZW5ndGggMAoxMjk0NDQzNjM0LjAxMjkzMSBJUCA1LjYuNy44LjgwID4gMi4zLjQuNS42Mjk4
NzogRmxhZ3MgW1MuXSwgc2VxIDE3NjE0MzA4MjYsIGFjayAxMzk3Mjk4NTc2LCB3aW4gNTc5Miwg
b3B0aW9ucyBbbXNzIDE0NjAsc2Fja09LLFRTIHZhbCA3NjAyMzUxOTAgZWNyIDU3NjQ5NzA1NSxu
b3Asd3NjYWxlIDVdLCBsZW5ndGggMAoxMjk0NDQzNjM0LjY1NjYyNSBJUCA1LjYuNy44LjgwID4g
Mi4zLjQuNS42Mjk4NzogRmxhZ3MgW1MuXSwgc2VxIDE3NjE0MzA4MjYsIGFjayAxMzk3Mjk4NTc2
LCB3aW4gNTc5Miwgb3B0aW9ucyBbbXNzIDE0NjAsc2Fja09LLFRTIHZhbCA3NjAyMzU4MzQgZWNy
IDU3NjQ5NzA1NSxub3Asd3NjYWxlIDVdLCBsZW5ndGggMAoxMjk0NDQzNjM0LjkyNTk3MCBJUCAy
LjMuNC41LjYyOTg3ID4gNS42LjcuOC44MDogRmxhZ3MgWy5dLCBhY2sgMSwgd2luIDMzMzA0LCBv
cHRpb25zIFtub3Asbm9wLFRTIHZhbCA1NzY0OTcwNjQgZWNyIDc2MDIzNTE5MF0sIGxlbmd0aCAw
Cgo=
--0016e65a0d30a3e1fd0499892e22--
