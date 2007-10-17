From: Chuck Ebbert <cebbert@redhat.com>
Subject: Re: bizarre network timing problem
Date: Wed, 17 Oct 2007 17:17:18 -0400
Message-ID: <47167BDE.4000103@redhat.com>
References: <20071017205127.GA21334@codeblau.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, Netdev <netdev@vger.kernel.org>
To: Felix von Leitner <felix-linuxkernel@fefe.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:54875 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755498AbXJQVRp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 17:17:45 -0400
In-Reply-To: <20071017205127.GA21334@codeblau.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/17/2007 04:51 PM, Felix von Leitner wrote:
> I wrote a small read-only SMB server, and wanted to see how fast it was.
> So I used smbget to download a moderately large file from it via localhost.
> smbget only got ~70 KB/sec.
> 
> This is what the view from strace -tt on the server is:
> 
> 22:44:58.812467 read(8, "\0\0\0007\377SMB.\0\0\0\0\10\1\310\0\0\0\0\0\0\0\0\0\0\0\0\0\0\232\3"..., 8192) = 59
> 22:44:58.812619 mmap(NULL, 8192, PROT_READ|PROT_WRITE, MAP_PRIVATE|MAP_ANONYMOUS, -1, 0) = 0x2b46b8e5e000
> 22:44:58.812729 fcntl(9, F_GETFL)       = 0x8000 (flags O_RDONLY|O_LARGEFILE)
> 22:44:58.812847 epoll_ctl(7, EPOLL_CTL_DEL, 8, {0, {u32=8, u64=13323248792850399240}}) = 0
> 22:44:58.812946 epoll_ctl(7, EPOLL_CTL_ADD, 8, {EPOLLOUT, {u32=8, u64=18251433459580936}}) = 0
> 22:44:58.813039 epoll_wait(7, {{EPOLLOUT, {u32=8, u64=18251433459580936}}}, 100, 442) = 1
> 22:44:58.813132 setsockopt(8, SOL_TCP, TCP_CORK, [1], 4) = 0
> 22:44:58.813215 write(8, "\0\0\372<\377SMB.\0\0\0\0\200A\300\0\0\0\0\0\0\0\0\0\0\0\0\0\0\232\3"..., 64) = 64
> 22:44:58.813323 sendfile(8, 9, [128000], 64000) = 64000
> 22:44:58.813430 setsockopt(8, SOL_TCP, TCP_CORK, [0], 4) = 0
> 22:44:58.813511 munmap(0x2b46b8e5e000, 8192) = 0
> 22:44:58.813600 epoll_wait(7, {{EPOLLOUT, {u32=8, u64=18251433459580936}}}, 100, 442) = 1
> 22:44:58.813693 epoll_ctl(7, EPOLL_CTL_DEL, 8, {0, {u32=8, u64=8}}) = 0
> 22:44:58.813778 epoll_ctl(7, EPOLL_CTL_ADD, 8, {EPOLLIN, {u32=8, u64=18252000395264008}}) = 0
> 22:44:58.813869 epoll_wait(7, {}, 100, 441) = 0
> 22:44:59.255789 epoll_wait(7, {{EPOLLIN, {u32=8, u64=18252000395264008}}}, 100, 999) = 1
> 22:44:59.688519 read(8, "\0\0\0007\377SMB.\0\0\0\0\10\1\310\0\0\0\0\0\0\0\0\0\0\0\0\0\0\232\3"..., 8192) = 59
> 
> 
> As you can see, the time difference between reading the query and writing the
> result is very small, but there is a big delay before receiving the next request.
> 
> This is the view from a sniffer on the lo interface:
> 
> 1192653899.688385    127.0.0.1 -> 127.0.0.1    SMB Read AndX Request, FID: 0x0001, 64000 bytes at offset 192000
> 1192653899.688399    127.0.0.1 -> 127.0.0.1    TCP 445 > 42990 [ACK] Seq=192660 Ack=779 Win=33920 Len=0 TSV=359208 TSER=359208
> 1192653899.895725    127.0.0.1 -> 127.0.0.1    SMB [TCP Window Full] Read AndX Response, FID: 0x0001, 64000 bytes
> 1192653899.895793    127.0.0.1 -> 127.0.0.1    TCP 42990 > 445 [ACK] Seq=779 Ack=204948 Win=12288 Len=0 TSV=359260 TSER=359260
> 1192653899.895805    127.0.0.1 -> 127.0.0.1    NBSS NBSS Continuation Message
> 1192653899.935725    127.0.0.1 -> 127.0.0.1    TCP 42990 > 445 [ACK] Seq=779 Ack=209044 Win=12288 Len=0 TSV=359270 TSER=359260
> 1192653900.147739    127.0.0.1 -> 127.0.0.1    NBSS [TCP Window Full] NBSS Continuation Message
> 1192653900.147767    127.0.0.1 -> 127.0.0.1    TCP [TCP ZeroWindow] 42990 > 445 [ACK] Seq=779 Ack=221332 Win=0 Len=0 TSV=359323 TSER=359323
> 1192653900.147807    127.0.0.1 -> 127.0.0.1    TCP [TCP Window Update] 42990 > 445 [ACK] Seq=779 Ack=221332 Win=12288 Len=0 TSV=359323 TSER=359323
> 1192653900.147815    127.0.0.1 -> 127.0.0.1    NBSS NBSS Continuation Message
> 1192653900.147837    127.0.0.1 -> 127.0.0.1    TCP 42990 > 445 [ACK] Seq=779 Ack=225428 Win=12288 Len=0 TSV=359323 TSER=359323
> 1192653900.355754    127.0.0.1 -> 127.0.0.1    NBSS [TCP Window Full] NBSS Continuation Message
> 1192653900.355782    127.0.0.1 -> 127.0.0.1    TCP [TCP ZeroWindow] 42990 > 445 [ACK] Seq=779 Ack=237716 Win=0 Len=0 TSV=359375 TSER=359375
> 1192653900.355820    127.0.0.1 -> 127.0.0.1    TCP [TCP Window Update] 42990 > 445 [ACK] Seq=779 Ack=237716 Win=12288 Len=0 TSV=359375 TSER=359375
> 1192653900.355829    127.0.0.1 -> 127.0.0.1    NBSS NBSS Continuation Message
> 1192653900.355849    127.0.0.1 -> 127.0.0.1    TCP 42990 > 445 [ACK] Seq=779 Ack=241812 Win=12288 Len=0 TSV=359375 TSER=359375
> 1192653900.563766    127.0.0.1 -> 127.0.0.1    NBSS [TCP Window Full] NBSS Continuation Message
> 1192653900.563794    127.0.0.1 -> 127.0.0.1    TCP [TCP ZeroWindow] 42990 > 445 [ACK] Seq=779 Ack=254100 Win=0 Len=0 TSV=359427 TSER=359427
> 1192653900.563831    127.0.0.1 -> 127.0.0.1    TCP [TCP Window Update] 42990 > 445 [ACK] Seq=779 Ack=254100 Win=12288 Len=0 TSV=359427 TSER=359427
> 1192653900.563839    127.0.0.1 -> 127.0.0.1    NBSS NBSS Continuation Message
> 1192653900.563858    127.0.0.1 -> 127.0.0.1    TCP 42990 > 445 [ACK] Seq=779 Ack=256724 Win=12288 Len=0 TSV=359427 TSER=359427
> 1192653900.564444    127.0.0.1 -> 127.0.0.1    SMB Read AndX Request, FID: 0x0001, 64000 bytes at offset 256000
> 
> 
> Note the delay between sending the response and getting the reply.
> Also note that there is almost no delay between getting the reply and sending
> the next request.
> 
> My understanding of TCP_CORK from the tcp(7) man page is that it should flush
> out the data immediately, but the network trace seems to suggest that there is
> a 200 ms delay between the request and the outgoing data.  tcp(7) says there is
> a 200 ms delay for sending out data when the socket is in corked mode, so
> uncorking does not appear to work.
> 
> 
> Now for the strange part: the same code works without a 200 ms delay
> over ethernet.  The delay only appears on the loopback interface.
> 
> Also, on my home desktop, which is also running 2.6.22, there is no
> delay even on loopback.
> 
> I tried 2.6.23 on my notebook, but the effect is the same.
> 
> Any ideas what could cause this?
> 

(cc: netdev)
