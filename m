From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH] net: Revert "fib_trie: use seq_file_net rather than seq->private"
Date: Wed, 04 Jun 2014 16:44:09 -0600
Message-ID: <538FA139.4020501@gmail.com>
References: <1401919352-32263-1-git-send-email-sasha.levin@oracle.com> <538F99A2.2090102@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Sasha Levin <sasha.levin@oracle.com>, davem@davemloft.net,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f53.google.com ([209.85.160.53]:49173 "EHLO
	mail-pb0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751505AbaFDWoN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 18:44:13 -0400
In-Reply-To: <538F99A2.2090102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 6/4/14, 4:11 PM, David Ahern wrote:
> On 6/4/14, 4:02 PM, Sasha Levin wrote:
>> This reverts commit 30f38d2fdd79f13fc929489f7e6e517b4a4bfe63.
>>
>> fib_triestat is surrounded by a big lie: while it claims that it's a
>> seq_file (fib_triestat_seq_open, fib_triestat_seq_show), it isn't:
>>
>>     static const struct file_operations fib_triestat_fops = {
>>             .owner  = THIS_MODULE,
>>             .open   = fib_triestat_seq_open,
>>             .read   = seq_read,
>>             .llseek = seq_lseek,
>>             .release = single_release_net,
>>     };
>>
>> Yes, fib_triestat is just a regular file.

If you compare fib_trie to fib_triestat the only difference is the use 
of single_open_net and single_release_net by fib_triestat.

single_open_net is a wrapper to single_open passing struct net as the 
private data. single_open is for seq_files:


int single_open(struct file *file, int (*show)(struct seq_file *, void *),
         void *data)
{
     struct seq_operations *op = kmalloc(sizeof(*op), GFP_KERNEL);
     int res = -ENOMEM;

     if (op) {
         op->start = single_start;
         op->next = single_next;
         op->stop = single_stop;
         op->show = show;
         res = seq_open(file, op);
         if (!res)
             ((struct seq_file *)file->private_data)->private = data;

Where is the problem using seq_file_net in fib_triestat_seq_show:

static int fib_triestat_seq_show(struct seq_file *seq, void *v)
{
     struct net *net = (struct net *)seq->private;

where

static inline struct net *seq_file_net(struct seq_file *seq)
{
#ifdef CONFIG_NET_NS
     return ((struct seq_net_private *)seq->private)->net;
#else
     return &init_net;
#endif
}

David
