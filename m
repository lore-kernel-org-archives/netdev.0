From: Donatas Abraitis <donatas.abraitis@gmail.com>
Subject: tcp_update_metrics() fail fast before declaring variables
Date: Fri, 7 Aug 2015 22:49:48 +0300
Message-ID: <CAPF+HwUVUeYr8yB+qR0RAMOSzcmPks7VzVQFfKNNFW-JQYi8jw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f179.google.com ([209.85.212.179]:35096 "EHLO
	mail-wi0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751641AbbHGTtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Aug 2015 15:49:49 -0400
Received: by wibxm9 with SMTP id xm9so73509577wib.0
        for <netdev@vger.kernel.org>; Fri, 07 Aug 2015 12:49:48 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi folks,

one short question regarding net.ipv4.tcp_no_metrics_save sysctl
parameter. Code snippet is actually the following:

void tcp_update_metrics(struct sock *sk)
{
  struct tcp_sock *tp = tcp_sk(sk);
  struct dst_entry *dst = __sk_dst_get(sk);

  if (sysctl_tcp_nometrics_save)
    return;

Why this 'if' statement can't be moved before variables? I think fail
fast could save some instructions in this place. Any thoughts?

Here is the performance benchmarking results:

Test #1 (sysctl -w net.ipv4.tcp_no_metrics_save=0)
sum: 79726, avg: 1295ns
min: 453ns, max: 16487ns

Test #2 (sysctl -w net.ipv4.tcp_no_metrics_save=1)
sum: 77515, avg: 1181ns
min: 431ns, max: 15989ns

Benchmarked with Systemtap:

global c;
probe kernel.function("tcp_update_metrics").return
{
        c <<< (gettimeofday_ns() - @entry(gettimeofday_ns()));
}
probe timer.s(60)
{
        printf("sum: %d, avg: %dns\n", @count(c), @avg(c));
        printf("min: %dns, max: %dns\n", @min(c), @max(c));
        delete c;
        exit();
}
