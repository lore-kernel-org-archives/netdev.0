From: "Rob Hussey" <robjhussey@gmail.com>
Subject: Re: [PATCH] cfg80211: fix initialisation if built-in
Date: Mon, 10 Sep 2007 21:18:11 -0400
Message-ID: <6b8cef970709101818g72366544ve1a75804f79499e3@mail.gmail.com>
References: <1189424685.4506.63.camel@johannes.berg>
	 <aec7e5c30709101804p337084e9o63b5bcb4f007828@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "Johannes Berg" <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>, stable@kernel.org
To: "Magnus Damm" <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.180]:40029 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932821AbXIKBSO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 Sep 2007 21:18:14 -0400
Received: by wa-out-1112.google.com with SMTP id v27so1775930wah
        for <netdev@vger.kernel.org>; Mon, 10 Sep 2007 18:18:11 -0700 (PDT)
In-Reply-To: <aec7e5c30709101804p337084e9o63b5bcb4f007828@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 9/10/07, Magnus Damm <magnus.damm@gmail.com> wrote:
> -module_init(rate_control_simple_init);
> +//module_init(rate_control_simple_init);
> +postcore_initcall(rate_control_simple_init);
>  module_exit(rate_control_simple_exit);
>
>  MODULE_DESCRIPTION("Simple rate control algorithm for ieee80211");

Same problem here, except with the rt2x00 driver. I changed it to
subsys_initcall(rate_control_simple_init), which also worked. I also
found that without this change, it was failing at this point in
ieee80211_rate.c:

ieee80211_try_rate_control_ops_get(const char *name)
{
        struct rate_control_alg *alg;
        struct rate_control_ops *ops = NULL;

        mutex_lock(&rate_ctrl_mutex);
        list_for_each_entry(alg, &rate_ctrl_algs, list) {   <===== Here
                if (!name || !strcmp(alg->ops->name, name))
                        if (try_module_get(alg->ops->module)) {
                                ops = alg->ops;
                                break;
                        }
